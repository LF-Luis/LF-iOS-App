//
//  User.swift
//  CameraToAws
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit

class MainUser: NSObject {

    /*
     The purpose of this class is to interact with data of the User of this phone. This class
     provides a layer to store and retrieve the User's simple they that they have inputed to our
     app such as full name and phone number.
     This class also handles the unique User ID (GUIID) that our back-end assigns to the User.
     */

    var firstName: String? = nil
    var lastName: String? = nil
    var phoneNumber: String? = nil
    private var gUIID: String? = nil
    private var phoneNumberForDisplay: String? = nil

    /*
     * Only set gID when the User first registers or logs in again.
     */
    func set(gUIID gID: String) {
        let defaults = UserDefaults.standard
        defaults.set(gID, forKey: AppSettingKeys.gUUID)
        self.gUIID = gID
    }

    func getGUIID() -> String? {
        if self.gUIID != nil { return self.gUIID! }

        let defaults = UserDefaults.standard
        if defaults.object(forKey: AppSettingKeys.gUUID) != nil {
            return defaults.string(forKey: AppSettingKeys.gUUID)!
        }
        else {
            return nil
        }
    }
    
    /*
     * Return: Returns stored int phone number in string form, e.g.: 123-456-7890
     *         Note: This functiondoes not check if phone number has been set. If
     *               no phone number has been set, then an empty string is returned.
     */
    func getPhoneNumberForDisplay() -> String {
        
        if phoneNumberForDisplay != nil {
            return self.phoneNumberForDisplay!
        }
        
        if phoneNumber != nil {
            self.phoneNumberForDisplay = self.createPhoneNumberForDisplay(phoneNumber: self.phoneNumber!)
            return self.phoneNumberForDisplay!
        }

        return ""
    }
    
    /*
     * Return: Returns stored int phone number in string form, e.g.: 123-456-7890
     *         Note: This function assumes that the correct format of a phone number
     *               is being used, and that it is 10 numbers long. Else, it will fail
     *               due to index not eisting.
     */
    private func createPhoneNumberForDisplay(phoneNumber pN: String) -> String {
        
        if pN.count != 10 {
            return pN
        }
        
        let pNArr: Array<Int> = pN.compactMap{Int(String($0))}
        
        func pNArrToString(startIndx sI: Int, endIndex eI: Int) -> String {
            let strArr = pNArr[sI...eI].map { String($0) }
            return strArr.joined()
        }
        
        let a = pNArrToString(startIndx: 0, endIndex: 2)
        let b = pNArrToString(startIndx: 3, endIndex: 5)
        let c = pNArrToString(startIndx: 6, endIndex: 9)
        
        return a + "-" + b + "-" + c
    }
    
    /*
     * Return: If the values are already stored or they can be retrieved from UserDefaults, then this
     * will return the following: (firstName, lastName, phoneNumber). Otherwise, nil is returned.
     */
    func getValues() -> (String, String, String)? {
        
//        if firstName != nil && lastName != nil && phoneNumber != nil {
//            return (self.firstName!, self.lastName!, self.phoneNumber!)
//        }
        
        let defaults = UserDefaults.standard
        
        var fN = String()
        var lN = String()
        var pN = String()
        
        if defaults.object(forKey: AppSettingKeys.firstName) != nil {
            fN = defaults.string(forKey: AppSettingKeys.firstName)!
        }
        else {
            return nil
        }
        
        if defaults.object(forKey: AppSettingKeys.lastName) != nil {
            lN = defaults.string(forKey: AppSettingKeys.lastName)!
        }
        else {
            return nil
        }
        
        if defaults.object(forKey: AppSettingKeys.phoneNumber) != nil {
            pN = defaults.string(forKey: AppSettingKeys.phoneNumber)!
        }
        else {
            return nil
        }
        
        self.firstName = fN
        self.lastName = lN
        self.phoneNumber = pN
        
        return(fN, lN, pN)
    }
    
    func setValues(firstName: String, lastName: String, phoneNumber: Int) -> Bool {
        let retVal = self.setValues(firstName: firstName, lastName: lastName, phoneNumber: String(phoneNumber))
        return retVal
    }
    
    func setValues(firstName: String, lastName: String, phoneNumber: String) -> Bool {
        
        var pN = String()
        var retVal = false

        // Accepting phone numbers that are 10 continous numbers, or 12 characters, where the extra
        // two characters are "-" separating the phone number.
        if phoneNumber.count == 10 {
            pN = phoneNumber
            retVal = true
        }
        else if phoneNumber.count == 12 {
            pN = phoneNumber.replacingOccurrences(of: "-", with: "")
            retVal = true
        }
        
        if retVal == false { return retVal }
        
        let defaults = UserDefaults.standard
        defaults.set(firstName, forKey: AppSettingKeys.firstName)
        defaults.set(lastName, forKey: AppSettingKeys.lastName)
        defaults.set(pN, forKey: AppSettingKeys.phoneNumber)
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = pN
        return retVal
    }

    /**
     Delete all User data that is retrieved by the User class.
     */
    func deleteAllData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: AppSettingKeys.firstName)
        defaults.removeObject(forKey: AppSettingKeys.lastName)
        defaults.removeObject(forKey: AppSettingKeys.phoneNumber)
        defaults.removeObject(forKey: AppSettingKeys.gUUID)
    }

}

