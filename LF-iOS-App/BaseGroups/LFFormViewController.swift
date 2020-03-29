//
//  old: BaseFormVC.swift
//  LFFormViewController.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

class LFFormViewController: FormViewController {

    private let cellContentWidth = 0.909 *  AppSize.screenWidth

    var navigationTitle: String? {
        didSet {
            if let str = navigationTitle {
                self.navigationItem.title = str
            }
        }
    }
//
//    let navigationLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = ""
//        lbl.font = UIFont(name: "SF-Pro-Display-Light.otf", size: UIFont.systemFontSize)
//        lbl.textColor = UIColor.black
//        lbl.sizeToFit()
//        return lbl
//    }()
//
    // Form
    var regitrationFormOptionsBackup : RowNavigationOptions?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = navigationTitle

        self.view.backgroundColor = UIColor.white
        self.tableView.backgroundColor = UIColor.white
        self.tableView?.showsVerticalScrollIndicator = false
        self.tableView?.showsHorizontalScrollIndicator = false

        // Form options
        navigationOptions = RowNavigationOptions.Enabled.union(.SkipCanNotBecomeFirstResponderRow)
        regitrationFormOptionsBackup = navigationOptions
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: AppFonts.navBar(size: 18)]
        navigationItem.largeTitleDisplayMode = .never
    }
    
}
