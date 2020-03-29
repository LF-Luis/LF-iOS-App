//
//  SettingsViewController.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

class SettingsVC: LFFormViewController {

    private let mainUser = MainUser()
    private var vibSettingSwitch = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "Settings"
        navigationTitle = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: AppSettingKeys.inAppVibSettingBool) != nil {
            vibSettingSwitch = defaults.bool(forKey: AppSettingKeys.inAppVibSettingBool)
        }
        
        _ = mainUser.getValues()
        _ = mainUser.getPhoneNumberForDisplay()
        
        loadForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // Storing setting values
//        let valuesDictionary = form.values()
//        let settVal = valuesDictionary["inAppVibSwitch"] as! Bool
//        let defaults = UserDefaults.standard
//        defaults.set(settVal, forKey: AppSettingKeys.inAppVibSettingBool)

    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.font = AppFonts.formFooter
        }
    }
    
    func editInfoAction() {
        let editUserInfo = EditUserInfo()
        self.navigationController?.pushViewController(editUserInfo, animated: true)
    }

    func logOut() {
        // Post message to subscribes (in this case HomeCollectionVC) that User has logged out
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .didLogOut, object: nil)
    }

    // MARK: Form
    
    func loadForm() {
        
        form =
            
            Section(header: "Personal Information", footer: "This information is well protected by our service.")
            
            <<< NameRow() {
                $0.title = "First Name"
                $0.value = mainUser.firstName
                $0.disabled = true
            }
            
            <<< NameRow() {
                $0.title = "Last Name"
                $0.value = mainUser.lastName
                $0.disabled = true
            }
            
            <<< PhoneRow() {
                $0.title = "Phone Number"
                $0.value = mainUser.getPhoneNumberForDisplay()
                $0.disabled = true
                }
            
//            <<< ButtonRow() { (row: ButtonRow) -> Void in
//                row.title = "Edit Info"
//                }
//                .cellUpdate { cell, row in
//                    cell.textLabel!.textColor = AppColors.mainColor
//                }
//                .onCellSelection({ (cell, row) in
//                    self.editInfoAction()
//                })

            +++ Section()
            
            <<< LabelRow () {
                $0.title = "Version"
                if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    $0.value = text
                }
                }.cellSetup({ (cell: LabelCellOf<String>, _: LabelRow) in
//                    cell.textLabel?.font = AppFonts.form
//                    cell.detailTextLabel?.font = AppFonts.form
                })
            
            <<< ButtonRow() {
                $0.title = "Official Website"
                
                let vC = WebViewController()
                vC.setUp(navTitle: "Project", ViewURL: "https://www.apple.com")
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { vC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
                }.cellSetup({ (cell, _) in
//                    cell.textLabel?.font = AppFonts.form
                })
            
            <<< ButtonRow() {
                $0.title = "Terms of Service"
                let vC = WebViewController()
                vC.setUp(navTitle: "Terms of Service", ViewURL: "https://www.apple.com")
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { vC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
                }.cellSetup({ (cell, _) in
//                    cell.textLabel?.font = AppFonts.form
                })
            
            <<< ButtonRow() {
                $0.title = "Privacy Policy"
                let vC = WebViewController()
                vC.setUp(navTitle: "Privacy Statement", ViewURL: "https://www.apple.com")
                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { vC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
                }.cellSetup({ (cell, _) in
//                    cell.textLabel?.font = AppFonts.form
                })
            
//            +++ Section(footer: "In-App Vibration Alert is used by this Project while the app is open to alert you when a beacon has been discovered.")
//            
//            <<< SwitchRow("inAppVibSwitch") {
//                $0.title = "In-App Vibration Alert"
//                $0.value = self.vibSettingSwitch
//                }.cellSetup({ (cell, _) in
////                    cell.textLabel?.font = AppFonts.form
//                })
//            
            +++ Section()

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Log Out"
                }
                .cellUpdate { cell, row in
                    cell.textLabel!.textColor = AppColors.cancelRed
                }
                .onCellSelection({ (cell, row) in
                    self.logOut()
                })

    }
    
}
