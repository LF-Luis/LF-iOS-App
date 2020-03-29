//
//  BaseFormVC.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

class BaseFormVC: FormViewController {
    
//    var networkService: NetworkProtocol?
    
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        networkService = NetworkService()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        
        // Form options
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
    }
    
//    func handleNetworkCallError(_ error : NSError) -> Void {
//        ViewControllerShared.handleNetworkCallError(error, networkService: networkService!, viewController: self)
//    }
    
}
