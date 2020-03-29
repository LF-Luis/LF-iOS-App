//
//  EditUserInfo.swift
//  ServiceQueue
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

/*
 * At the moment, this class is only being used the first time a User comes into our app and their
 * personal data has not yet been set-up.
 */

class EditUserInfo: LFFormViewController, UITextViewDelegate { // UITextFieldDelegate {

    private let mainUser = MainUser()

    lazy private var attributedPolicyTextView: UITextView = {
        // TextView setup
        let textView = UITextView()
        textView.frame = CGRect(x: 0, y: 0, width: 0, height: 45)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSecureTextEntry = false
        textView.textAlignment = .center

        // Attributed text setup
        // Read our Privacy Policy. Tap “Agree & continue” to accept the Terms of Service.

        let mainAttributedString = NSMutableAttributedString(string: "Read our ")
        let privacyPolicy = NSMutableAttributedString(string: "Privacy Policy")
        privacyPolicy.addAttribute(.link, value: "https://www.apple.com", range: NSRange(location: 0, length: privacyPolicy.length))
        let midAttributedString = NSMutableAttributedString(string: ". Tap \"Agree & Continue\" to accept the ")
        let termsOfService = NSMutableAttributedString(string: "Terms of Service")
        termsOfService.addAttribute(.link, value: "https://www.apple.com", range: NSRange(location: 0, length: termsOfService.length))
        let endAttributedString = NSMutableAttributedString(string: ".")

        mainAttributedString.append(privacyPolicy)
        mainAttributedString.append(midAttributedString)
        mainAttributedString.append(termsOfService)
        mainAttributedString.append(endAttributedString)

        // Attributed paragraph setup

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        mainAttributedString.addAttributes([NSAttributedStringKey.paragraphStyle : paragraphStyle],
                                           range: NSRange(location: 0, length: mainAttributedString.length))

        textView.attributedText = mainAttributedString
        textView.delegate = self
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationTitle = "Your Information"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        _ = mainUser.getValues()
        _ = mainUser.getPhoneNumberForDisplay()
        
        loadForm()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func registerAction() {

#if NO_WEB_API_TESTING
        // For testing without web APIs, move on to a VerifyFormContoller without having to actually
        // register User.
        let verificationForm = VerifyFormContoller()
        self.navigationController?.pushViewController(verificationForm, animated: true)
        return
#endif
        // UI Change, set overlay with loading screen
        let overlay = LFOverlay()
        overlay.showOverlayOverAppWindow(withTitle: nil)

        // Check if form is fully completed and if values can be extracted a Strings
        guard
            let firstName = (form.rowBy(tag: "fN") as NameRow?)?.value,
            let lastName = (form.rowBy(tag: "lN") as NameRow?)?.value,
            let phoneNumber = (form.rowBy(tag: "pN") as PhoneRow?)?.value
            else {
                // Form not fully completed
                Alerts.presentSimple(title: "Project", message: "Please fully complete the form.", dissmissString: "Ok", withController: self)
                overlay.endOverlay()
                return
        }

        if phoneNumber.count != 10 {
            Alerts.presentSimple(title: "Project", message: "Please enter a 10-digit phone number.", dissmissString: "Ok", withController: self)
            overlay.endOverlay()
            return
        }

        UserVerification.register(firstName: firstName, lastName: lastName, phoneNumber: phoneNumber) { (didSucceed: Bool) in

            // UI change, end overlay
            overlay.endOverlay()

            if didSucceed {
                let verificationForm = VerifyFormContoller()
                self.navigationController?.pushViewController(verificationForm, animated: true)
            }
            else {
                Alerts.presentSimple(title: "Project", message: "Registration unexpectedly failed, please try again.", dissmissString: "Ok", withController: self)
            }

        }

    }

//    func cancelAction() {
//        // Go back to previous view controller
//        if navigationController?.popViewController(animated: true) == nil {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }

//    // MARK:- UITextFieldDelegate Methods (mainly for PhoneRow of the Form)
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
////        let decimalChars = CharacterSet.decimalDigits
////        let decimalRange = string.rangeOfCharacter(from: decimalChars)
////
////        if decimalRange == nil {
////
////        }
//        // if string contains any letter: do not let copy
//        // if string + textField.text.count > 10 : do not let copy
//
//        print("print(textField.text?.count): \(textField.text?.count)")
//        print("print(range.length): \(range.length)")
//        print("print(range.location): \(range.location)")
//        print("print(string): \(string)")
//
//
////        let textCharCount = textField.text?.count ?? 0
////
////        if textCharCount == 3 {
////            textField.text! = textField.text! + "-"
////        }
//
////        if textField.tag == phoneRowTag {
////            textField.text = ""
////        }
//        return true
//    }
//
//    private var phoneRow_shouldAddDash = true
//
//    @objc func textFieldDidChange(_ textField: UITextField) {
//
//        print(" -> textField.text: \(textField.text)")
//
//        let textCharCount = textField.text?.count ?? 0
//
//        if textCharCount == 3 && phoneRow_shouldAddDash == true {
//            textField.text! = textField.text! + "-"
//            phoneRow_shouldAddDash = false
//        }
//        else {
//            phoneRow_shouldAddDash = true
//        }
//
//    }

    // MARK:- Form
    
    func loadForm() {

        let headerString = "This information is used for the service"

        let footerString = "Your phone number will be used to verify your account."
            + "\n"
            + "\n"

        form =
            
            Section(header: headerString, footer: footerString)

            <<< NameRow("fN") {
                $0.title = "First Name"
                $0.placeholder = "Jane"
                $0.value = mainUser.firstName
            }
            
            <<< NameRow("lN") {
                $0.title = "Last Name"
                $0.placeholder = "Monroe"
                $0.value = mainUser.lastName
            }
            
            <<< PhoneRow("pN") {
                $0.title = "Phone Number"
                $0.placeholder = "10-Digits (US)"
                $0.value = mainUser.phoneNumber

                }
//                .cellUpdate({ (cell: PhoneCell, _: PhoneRow) in
//                    cell.textField.tag = self.phoneRowTag
//                    cell.textField.delegate = self
//                    cell.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//                })

            +++ Section() {
                $0.header = HeaderFooterView<UITextView>(.callback({ () -> UITextView in
                    return self.attributedPolicyTextView
                }))
            }

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Agree & Continue"
            }
            .cellUpdate { cell, row in
                cell.textLabel!.textColor = AppColors.mainColor
            }
            .onCellSelection({ (cell, row) in
                self.registerAction()
            })
        
//            <<< ButtonRow() { (row: ButtonRow) -> Void in
//                row.title = "Cancel"
//            }
//            .cellUpdate { cell, row in
//                cell.textLabel!.textColor = AppColors.cancelRed
//            }
//            .onCellSelection({ (cell, row) in
//                self.cancelAction()
//            })

    }
}


