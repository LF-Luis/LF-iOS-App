//
//  UserVerification.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import RealmSwift

class UserVerification: NSObject {
    /*
     This class will deal with the various steps needed to register a User.
     There are two steps:
     (1) Register: The User puts in their info (first name, last name, phone number), and an API
        call returns a verification code.
     (2) Verification: The verification code is used to authenticate the User and the API returns
        a unique ID with which to constantly authenticate the User (GUUID).
     */

    //MARK: - Registration Steps

    class func register(
        firstName: String,
        lastName: String,
        phoneNumber: String,
        _ completion:@escaping (_ didSucceed: Bool) -> Void)
    {

        // Check that values were able to be parametrized
        guard let pD = ParametrizeForAPI.register(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber) else {
            Alerts.presentSimple(title: "Project", message: "Error registering, please try again.", dissmissString: "Ok")
            completion(false)
            return
        }

        // Send values back to DB. Wait for validatin code string. Store string in UserDefaults.
        // Use validation code to finish registration of User
        AzureAPI.postRegister(parameters: pD) { (verificationCode: String?) in
            if verificationCode != nil {

                let mainUser = MainUser()

                // Storing User's data, will be used in Verify process
                guard mainUser.setValues(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber) else {
                    // Values not set correctly
                    Alerts.presentSimple(title: "Project", message: "Error registering, please try again.", dissmissString: "Ok")
                    completion(false)
                    return
                }

                self.storeVerificationCode(code: verificationCode!)
                completion(true)
                return

            }
            else {
                completion(false)
                return
            }
        }

    }

    /**
     Verify registration with a one time passcode (OTP) that the User should have received via text
     message.

     In this method, the one time passcode, along with the stored verification string and other User
     information is sent to an API call to finish the registration or re-login of the User. After
     this succeeds, the verification code os deleted from permanent storage.

     */
    class func verifyRegistration(oneTimePasscode: String, _ completion:@escaping (_ didSucceed: Bool) -> Void) {

        // Check that verification is stored, and that values were able to be parametrized
        guard
            let verfCode = self.getVerificationCode(),
            let pD = ParametrizeForAPI.verifyRegistration(oneTimePasscode: oneTimePasscode, verificationCode: verfCode)
        else {
            Alerts.presentSimple(title: "Project", message: "Error verifying, please try again.", dissmissString: "Ok")
            completion(false)
            return
        }

        // Send verification data back DB for comfirmation
        // If successful, this (postRegistrationVerify) function will store the User's GUIID
        AzureAPI.postRegistrationVerify(parameters: pD) { (didSucceed: Bool) in
            if didSucceed {
                self.removeVerificationCode()
                completion(true)
            }
            else {
                completion(false)
            }
            return
        }

    }

    /**
     Perform neccessary steps, with respect to data being stored in the phone, to restart the
     rgistration process.
     */
    class func restartVerificationProcess() {
        let mU = MainUser()
        mU.deleteAllData()
        self.removeVerificationCode()

        // Deleting Realm data (which holds previous data) and next time any other User logs-in, and
        // goes to the Second Main View Controller, the data will be reloaded.
        do {
            let realm = try Realm()
            try realm.write { realm.deleteAll() }
        }
        catch {
            print("Error deleting Realm data when restarting verification, error: \(error).")
        }

        let defaults = UserDefaults.standard
        defaults.set(true, forKey: AppSettingKeys.shouldUpdateSecondMainViewWithAPI)

    }

    // MARK: - Handling Verification Code

    /*
     Store verification code using UserDefaults as part of the Registration process.
     NOTE: Once the registration process is completed, delete verification code from UserDefaults.
     @param: verification code as String
     */
    private class func storeVerificationCode(code: String) {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: AppSettingKeys.verificationCode)
    }

    private class func getVerificationCode() -> String? {

        guard let verificationCode = UserDefaults.standard.string(forKey: AppSettingKeys.verificationCode) else {
            return nil
        }

        return verificationCode

    }

    private class func removeVerificationCode() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: AppSettingKeys.verificationCode)
    }

    /**
     Public facing API to see if a verification code exists.

     If a verification code exists, this means that the User is in the second step of the
     verification process (see this class' description explaing "steps" of registration).
     */
    class func verificationCodeDoesExist() -> Bool {
        guard let _ = UserDefaults.standard.string(forKey: AppSettingKeys.verificationCode) else {
            return false
        }
        return true
    }

}
