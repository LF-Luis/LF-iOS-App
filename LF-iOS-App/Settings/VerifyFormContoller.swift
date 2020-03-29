//
//  VerifyFormContoller.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//


import UIKit
import Eureka


/*
 Perform the verification of the registration process.
 */
class VerifyFormContoller: LFFormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationTitle = "Verification"

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        loadForm()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func verifyAction() {

        // UI Change, set overlay with loading screen
        let overlay = LFOverlay()
        overlay.showOverlayOverAppWindow(withTitle: nil)

        // Check if form is fully completed and if values can be extracted a Strings
        guard let oneTimePasscode = (form.rowBy(tag: "oTP") as TextRow?)?.value else {
            // Form not fully completed
            Alerts.presentSimple(title: "Project", message: "Please enter verification code.", dissmissString: "Ok", withController: self)
            overlay.endOverlay()
            return
        }

        UserVerification.verifyRegistration(oneTimePasscode: oneTimePasscode) { (didScceed: Bool) in
            // UI change, end overlay
            overlay.endOverlay()
            if didScceed {
                // The main home view controller is waiting for this notification to
                // continue with its setup.
                NotificationCenter.default.post(name: .didFinishRegister, object: nil)

                // Go back to previous view controller
                if self.navigationController?.dismiss(animated: true, completion: nil) == nil {
                    self.dismiss(animated: true, completion: nil)
                }

            }
            else {
                Alerts.presentSimple(title: "Project", message: "Verification unexpectedly failed, please try again.", dissmissString: "Ok", withController: self)
            }
        }

    }

    func restartRegistrationProcess() {
        UserVerification.restartVerificationProcess()
        let editForm = EditUserInfo()
        self.navigationController?.pushViewController(editForm, animated: true)
    }

    // MARK: - Form

    func loadForm() {

        let firstHeaderString = "Let's verify it's you \n\n"
            + "Please enter the verification code you received via text message"

        let secondHeaderString = "Unable to verify? Try this:"

        form =

            Section(firstHeaderString)

            <<< TextRow("oTP") {
                $0.title = ""
                }.cellSetup({ (cell: TextCell, row: TextRow) in
                    cell.textField.textAlignment = NSTextAlignment.center
                    cell.textField.placeholder = "Enter Code"
                })

            +++ ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Verify"
                }
                .cellUpdate { cell, row in
                    cell.textLabel!.textColor = AppColors.mainColor
                }
                .onCellSelection({ (cell, row) in
                    self.verifyAction()
                })

            +++ Section(secondHeaderString)

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Get New Code"
                }
                .cellUpdate { cell, row in
                    cell.textLabel!.textColor = AppColors.cancelRed
                }
                .onCellSelection({ (cell, row) in
                    self.restartRegistrationProcess()
                })


    }
}


