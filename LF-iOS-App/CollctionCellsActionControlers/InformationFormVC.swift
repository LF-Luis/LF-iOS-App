//
//  InformationFormVC.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Eureka

/*
 View Cotroller (VC) with a Form View to show relevant information about a DataForBeacon object.
 */

class InformationFormVC: LFFormViewController {

    var dataForBeacon = DataForBeacon()
    private var viewCell: HomeCollectionViewCell!

    private var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = AppFonts.cellTitle()
        lbl.backgroundColor = .clear
        lbl.autoresizingMask = .flexibleWidth
        lbl.frame = CGRect(x: 0, y: 0, width: 20, height: 60)
        return lbl
    }()

    private var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.textAlignment = .center
        lbl.textColor = FontColor.darkAppFont
        lbl.font = AppFonts.cellDescription(size: 14.0)
        lbl.backgroundColor = .clear
        lbl.autoresizingMask = .flexibleWidth
        lbl.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
        return lbl
    }()

    private var longExtraTxtLbl: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.textAlignment = .center
        lbl.font = AppFonts.boldTitle(size: 16)
        lbl.backgroundColor = .clear
        lbl.autoresizingMask = .flexibleWidth
        lbl.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        lbl.textColor = AppColors.promotionRed
        return lbl
    }()

    private var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.autoresizingMask = .flexibleWidth
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: 20, height: 180)
        return iv
    }()

    /*
     When set to true, the views will be layed-out in such a way that when this view controller is
     shown, it will blur the background view-controller, and allow for "slide-down" action to remove
     controller from window.
     NOTE: If setting shouldConformToCardStyle to true, present view controller without animation so
     that the custom animations can happen.
    */
    var shouldConformToCardStyle = false
    private let offSetHeight: CGFloat = 55.0
    private let padding: CGFloat = 10
    private let topPadding: CGFloat = 20 //        AppSize.statusBarHeight + 10

    lazy private var dimmedView: UIView = {
        let v = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewGesture(_:)))
        v.addGestureRecognizer(tapGesture)
        v.backgroundColor = .clear
        return v
    }()

    lazy private var cancelImgView: UIImageView = {
        let iV = UIImageView()
        iV.backgroundColor = .clear
        iV.clipsToBounds = true
        iV.contentMode = .scaleToFill
        iV.image = UIImage(named: "slideDown")?.withRenderingMode(.alwaysTemplate)
        iV.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewGesture(_:)))
        iV.addGestureRecognizer(tapGesture)
        iV.tintColor = UIColor.rgb(red: 208, green: 208, blue: 208)
        iV.alpha = 0
        return iV
    }()

    /*
     This function should be called before the view controller is presented.
     */
    func setUp(withCell cell: HomeCollectionViewCell, shouldConformToCardStyle: Bool = false) {
        self.viewCell = cell

        self.dataForBeacon = cell.dataForBeacon
        self.shouldConformToCardStyle = shouldConformToCardStyle

        // set image for icon image
        self.iconImageView.image = cell.iconImg.image
        // set title text
        self.titleLabel.text = cell.dataForBeacon.mainName ?? ""
        // set subtitle text
        let metric1 = cell.dataForBeacon.metric1
        self.subtitleLabel.text = "\(metric1) Metric 1" + "\(metric1 == 1 ? "Value" : "Values")"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationTitle = "Info"

        if shouldConformToCardStyle {

            tableView.panGestureRecognizer.addTarget(self, action: #selector(panGestureRecognizerAction))

            view.backgroundColor = .clear
            tableView.backgroundColor = .white
            tableView.frame = CGRect(x: 0, y: AppSize.screenHeight, width: tableView.frame.width, height: tableView.frame.height - offSetHeight)
            tableView.layer.cornerRadius = AppSize.viewCornerRadius

            // Setting swipe down gesture
            let swipeDownGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
            view.addGestureRecognizer(swipeDownGesture)

            // Setup dimmedView
            self.dimmedView.frame = self.view.frame
            self.view.insertSubview(self.dimmedView, at: 0)

            // Setup cancel image
            view.addMultipleSubviews(cancelImgView)
            view.setTranslatesAutoresizingMaskIntoConstraintsFalse(cancelImgView)
            let widthAndHeight = offSetHeight - topPadding - padding
            cancelImgView.frame = CGRect(x: 0, y: self.topPadding, width: widthAndHeight, height: widthAndHeight)
            let cancelAtCenterX = NSLayoutConstraint(item: cancelImgView, attribute: .centerX, relatedBy: .equal, toItem: tableView, attribute: .centerX, multiplier: 1, constant: 0)
            view.addConstraints([cancelAtCenterX])
            view.addSubview(cancelImgView)

        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        if shouldConformToCardStyle {
            UIView.animate(withDuration: 1.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.05, options: .curveEaseIn, animations: {
                self.dimmedView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.75)
            }, completion: nil)
        }

        loadForm()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if shouldConformToCardStyle {
            UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.75, options: .curveEaseIn, animations: {
                self.tableView.frame.origin.y = self.offSetHeight
                self.cancelImgView.alpha = 1
                self.cancelImgView.frame.origin.y = self.topPadding
            }, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    /*
     Only allow the gesture of sliding down.
     When this gesture meets certain thresholds, the expandCellForActionAView will disappear
     */
    @objc private func panGestureRecognizerAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        let newY = gestureRecognizer.translation(in: self.view).y
        if newY < 0 { return }

        let velY = gestureRecognizer.velocity(in: self.view).y

        let locEnd = self.topPadding + newY - ( (velY > 0 ? velY : 0) * 0.065 )
        if locEnd < self.topPadding {
            self.cancelImgView.frame.origin.y = self.topPadding
        }
        else {
            self.cancelImgView.frame.origin.y = locEnd
        }

        if self.tableView.frame.origin.y >= self.offSetHeight {
            // Only start moving entire VC if the top of the VC view is being shown, i.e. it is at
            // offSetHeight or greater
            self.tableView.frame.origin.y = self.offSetHeight + newY
        }

        if gestureRecognizer.state == .ended {
            if velY >= 1500 || newY > 200 {
                // If meeting certain thresholds, dismiss current table view
                self.dismissWithCustomAnimation()
            }
            else {
                // If thresholds are not met, place view back in starting position
                UIView.animate(withDuration: 0.3) {
                    self.tableView.frame.origin.y = self.offSetHeight
                    self.cancelImgView.frame.origin.y = self.topPadding
                }
            }
        }

    }

    @objc private func dimmedViewGesture(_ gestureRecognizer:UITapGestureRecognizer){
        self.dismissWithCustomAnimation()
    }

    private func dismissWithCustomAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.75, options: .curveEaseOut, animations: {
            self.tableView.frame.origin.y = AppSize.screenHeight
            self.cancelImgView.frame.origin.y = AppSize.screenHeight
            self.dimmedView.backgroundColor = .clear
            self.cancelImgView.alpha = 0
        }, completion: { (didEnd: Bool) in
            if didEnd {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func cancelAction() {
        // Go back to previous view controller
        if navigationController?.popViewController(animated: true) == nil {
            self.dismiss(animated: !self.shouldConformToCardStyle, completion: nil)
        }
    }

    /*
     Given that User has selecter to call a phone number associated with a beacon, this function
     takes care of that. Once the User has confirmed, the phone call will be placed.
     */
    @objc private func callPhoneFromBeacon() {
        let mainName: String = dataForBeacon.mainName ?? ""
        guard let phoneNumber = dataForBeacon.bcnPhoneNum else {
            return
        }
        let alertTitle = "Project"
        let alertMessage = "Do you wish to call \(mainName) \n \(phoneNumber)?"
        Alerts.present(title: alertTitle, message: alertMessage, withController: self) {
            let urlNumber = URL(string: "tel://" + phoneNumber)
            UIApplication.shared.open(urlNumber!)
        }
    }

    /*
     Open dataForBeacon's address in Maps
     */
    @objc private func openInMapApp() {
        // FIXME: Add option to open with Google Maps app
        guard let realAddress = dataForBeacon.realAddress else {
            Alerts.presentSimple(title: "Project", message: "Could not open map, please try again.", dissmissString: "Ok", withController: self)
            return
        }
        Alerts.present(title: "Project", message: "Open in Maps", withController: self) {
            let mapWebUrl = URL(string: "http://maps.apple.com/?address=\(realAddress.replacingOccurrences(of: " ", with: "%20"))")
            UIApplication.shared.open(mapWebUrl!, options: [:], completionHandler: nil)
        }

    }

    // FIXME: Open in Webview instead of leaving app; use LFWebView
    /*
     Opens dataForBeacon's URL in Safari Web App
     */
    @objc private func openInSafariApp() {
        guard let beaconWebUrl = dataForBeacon.website else {
            Alerts.presentSimple(title: "Project", message: "Could not open website, please try again.", dissmissString: "Ok", withController: self)
            return
        }
        Alerts.present(title: "Project", message: "Open in Safari", withController: self) {
            let webUrl = URL(string: beaconWebUrl)!
            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
        }

    }

    /*
     Cancel Action A, which is tracked by dataForBeacon's didPerformActionA
     Note that Action A is performed inside of the ExpandCellForActionAHandler class
     */
    func cancelActionA() {
        UserStateManager.cancelActionA(ofDataBeacon: self.dataForBeacon,
                                       presentedOnVC: self,
                                       withActionAButtonReselected: false)
        { (didSucceed: Bool) in
            if didSucceed {
                self.viewCell.setToCanceledActionAState()
                self.dismissWithCustomAnimation()
            }
            return
        }
    }

    // MARK: Form

    func loadForm() {

        form =

            Section() {
                $0.header = HeaderFooterView<UIImageView>(.callback({ () -> UIImageView in
                    return self.iconImageView
                }))
                $0.footer = HeaderFooterView<UILabel>(.callback({ () -> UILabel in
                    return self.titleLabel
                }))
            }

            +++ Section() {
                $0.header = HeaderFooterView<UILabel>(.callback({ () -> UILabel in
                    return self.subtitleLabel
                }))
            }

            +++ Section() {
                $0.header = HeaderFooterView<UILabel>(.callback({ () -> UILabel in
                    self.longExtraTxtLbl.text = self.dataForBeacon.longExtraStr
                    return self.longExtraTxtLbl
                }))
                $0.hidden = Condition(booleanLiteral: (self.dataForBeacon.longExtraStr == nil))
            }

            +++ Section("Current Metrics")

            <<< LabelRow () {
                $0.title = "Value of Metric 2"
                $0.value = String(dataForBeacon.metric2)
            }

            <<< LabelRow () {
                $0.title = "Value of Metric 3"
                $0.value = String(dataForBeacon.metric3)
            }

//            +++ ButtonRow() {
//                $0.title = "Go To Website"
//
//                let vC = LFWebView()
//                vC.url = URL(string: "https://www.google.com")
//
////                let vC = WebViewController()
////                vC.setUp(navTitle: "Title", ViewURL: "https://www.google.com")
//                $0.presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { vC }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) } )
//                }.cellSetup({ (cell, _) in
////                    cell.textLabel?.font = AppFonts.form
//                })

            +++ Section("Information")

            <<< ButtonRow() {
                $0.title = "Go To Website"
                }.cellUpdate({ (cell: ButtonCellOf<String>, row: ButtonRow) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.editingAccessoryType = cell.accessoryType
                })
                .onCellSelection({ (buttonCellOf :ButtonCellOf<String>, buttonRow: ButtonRow) in
                    self.openInSafariApp()
                })

            <<< ButtonRow() {
                $0.title = "Call Beacon's Phone Number"
                }
                .cellUpdate({ (cell: ButtonCellOf<String>, row: ButtonRow) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.editingAccessoryType = cell.accessoryType
                })
                .onCellSelection({ (buttonCellOf :ButtonCellOf<String>, buttonRow: ButtonRow) in
                    self.callPhoneFromBeacon()
                })

//            +++ Section("Address") {
//                $0.hidden = Condition(booleanLiteral: self.dataForBeacon.realAddress == nil)
//            }

            <<< TextAreaRow() {
                $0.value = dataForBeacon.realAddress ?? ""
                $0.textAreaMode = .readOnly
                $0.textAreaHeight = .fixed(cellHeight: 55)
                $0.hidden = Condition(booleanLiteral: dataForBeacon.realAddress == nil)
                }.cellSetup({ (cell: TextAreaCell, row: TextAreaRow) in
                    cell.textView.isScrollEnabled = false
                    // FIXME: Make text selectable-able and copy-able
                })

            <<< ButtonRow() {
                $0.title = "Open in Maps"
                $0.hidden = Condition(booleanLiteral: dataForBeacon.realAddress == nil)
                }
                .cellUpdate({ (cell: ButtonCellOf<String>, row: ButtonRow) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.accessoryType = .disclosureIndicator
                    cell.editingAccessoryType = cell.accessoryType
                })
                .onCellSelection({ (buttonCellOf :ButtonCellOf<String>, buttonRow: ButtonRow) in
                    self.openInMapApp()
                })

            +++ Section()

            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Cancel Action A"
                row.hidden = Condition(booleanLiteral: (dataForBeacon.didPerformActionA == false || self.shouldConformToCardStyle == false))
                }
                .cellUpdate { cell, row in
                    cell.textLabel!.textColor = AppColors.cancelRed
                }
                .onCellSelection({ (cell, row) in
                    self.cancelActionA()
                })

    }
}

