//
//  HomeCollectionvVC.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//


import UIKit
import AudioToolbox
import DZNEmptyDataSet
import Onboard

extension HomeCollectionVC: HomeCollectionViewCellDelegate {

    func homeCollectionViewCell(performActionA fromCell: HomeCollectionViewCell) {
        expandCellForActionAHandler = ExpandCellForActionAHandler()
        expandCellForActionAHandler.expand(withCell: fromCell)
    }

    func homeCollectionViewCell(performActionB fromCell: HomeCollectionViewCell) {
        infoFormVC = InformationFormVC()
        infoFormVC.setUp(withCell: fromCell, shouldConformToCardStyle: true)
        infoFormVC.shouldConformToCardStyle = true
        infoFormVC.modalPresentationStyle = .overCurrentContext
        infoFormVC.definesPresentationContext = true
        //        let navController = UINavigationController(rootViewController: infoFormVC)
        //        navController.view.backgroundColor = .clear
        //        navController.setNavigationBarHidden(true, animated: false)
        //        navController.modalPresentationStyle = .overCurrentContext
        //        navController.definesPresentationContext = true
        //        self.present(navController, animated: false, completion: nil)
        self.present(infoFormVC, animated: false, completion: nil)
    }

}

class HomeCollectionVC: BaseCollectionVC, UserStateManagerDelegate {

    var expandCellForActionAHandler: ExpandCellForActionAHandler!
    var infoFormVC: InformationFormVC!

    private var headerView = HeaderViewCell()
    private var headerTitle = ""
    private var headerSubTitle = ""

    private var dataForBeacons = [DataForBeacon]()
    private var userStateManager: UserStateManager!

    private let cellId = "Cell"
    private let headerId = "headerId"

    private var shouldVibrateSett = true

    // MARK:- Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCollectionView()
        navBarSetup()
        setUpNotifObservers()

        // Testing without using web APIs (this is done mainly to test various UI changes)
#if NO_WEB_API_TESTING
        self.setUpUserStateManaging()
        return
#endif

        // The following flow is controlled by the fact if User's info has been set or not.
        // If it has not been set, the User is not allowed to use the app until it is set via
        // registration and verification.

        let mainUser = MainUser()
        var registrationNavController = UINavigationController()

        if mainUser.getValues() == nil && UserVerification.verificationCodeDoesExist() == false {
            // (Sign-up process) Launch onboarding, which is followed by registration

            var onboarding = UIViewController()

            onboarding = AppOnboarding.onboardingViewController { () in

                onboarding.dismiss(animated: true, completion: nil)

                // Registration process
                let editUserInfo = EditUserInfo()
                registrationNavController.interactivePopGestureRecognizer?.isEnabled = false
                registrationNavController = UINavigationController(rootViewController: editUserInfo)

                self.present(registrationNavController, animated: true, completion: nil)

            }

            self.present(onboarding, animated: true, completion: nil)

            return
        }

        if mainUser.getValues() != nil && UserVerification.verificationCodeDoesExist() == true {
            // (Verification process) Start from VerifyFormController
            let verificationForm = VerifyFormContoller()
            registrationNavController.interactivePopGestureRecognizer?.isEnabled = false
            registrationNavController = UINavigationController(rootViewController: verificationForm)
            self.present(registrationNavController, animated: true, completion: nil)
            return
        }

        if mainUser.getValues() != nil && UserVerification.verificationCodeDoesExist() == false {
            // User has registered succesfully, conttinue with app normally with verified User
            self.setUpUserStateManaging()
            return
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set-up ability to vibrate when new beacon is found
        // Needs to be checked every time User comes back to this view, as this ability may have
        // been changed in Settings.
        vibAlertSettingCheck()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: AppFonts.navBar()]
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    // MARK:- Setup Methods
    
    private func setUpNotifObservers() {
        // View controller will enter foreground
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForgound),
                                               name: .UIApplicationWillEnterForeground, object: nil)
        // User finished registration
        NotificationCenter.default.addObserver(self, selector: #selector(setUpUserStateManaging),
                                               name: .didFinishRegister, object: nil)
        // User has log out
        NotificationCenter.default.addObserver(self, selector: #selector(didLogOutStateManaging),
                                               name: .didLogOut, object: nil)
    }

    @objc private func setUpUserStateManaging() {
        userStateManager = UserStateManager()
        userStateManager.delegate = self
#if NO_BEACON_TESTING
        userStateManager.runTestNoBeacons()
#endif
#if NO_WEB_API_TESTING
        userStateManager.runTestNoWebAPI()
#endif
    }

    @objc private func didLogOutStateManaging(_ notification: NSNotification) {

        // Clear out any verification information
        UserVerification.restartVerificationProcess()
        // Stop working with UserStateManager (i.e. stop sniffing for beacons)
        userStateManager = UserStateManager()
        userStateManager.delegate = nil
        userStateManager.stopScanning()
        // Remove all data cached by app
        userStateManager.clearCachedData()
        // Reload data (to empty)
        self.dataForBeacons = []
        self.collectionView?.reloadData()

        // Load onboarding screen with registration/log-in at the end

        // Registration process
        let editUserInfo = EditUserInfo()
        let registrationNavController = UINavigationController(rootViewController: editUserInfo)
        registrationNavController.interactivePopGestureRecognizer?.isEnabled = false

        var onboarding = UIViewController()

        onboarding = AppOnboarding.onboardingViewController { () in
            onboarding.dismiss(animated: true, completion: nil)
            self.present(registrationNavController, animated: true, completion: nil)
        }

        self.present(onboarding, animated: true, completion: nil)

    }

    @objc private func willEnterForgound() {
        self.collectionView?.reloadData()
    }
    
    private func setUpCollectionView() {
        collectionView?.backgroundColor = AppColors.backgroundGray
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self

        // Register cell classes
        self.collectionView!.register(HomeCollectionViewCell.self,
                                      forCellWithReuseIdentifier: cellId)
        self.collectionView?.register(HeaderViewCell.self,
                                      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                      withReuseIdentifier: headerId)

        // Pull to refresh action
        self.setUpPullToRefresh()
    }
    
    private func navBarSetup() {
        
        // Set up nav. bar
        navigationItem.title = "Project"
#if NO_BEACON_TESTING
        navigationItem.title = "Project No Beacon Test"
#endif
#if NO_WEB_API_TESTING
        navigationItem.title = "Project No Web API Test"
#endif
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.shadowImage = UIImage()

        // Set up Settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.addTarget(self, action: #selector(self.navSettingsAction), for: .touchUpInside)
        settingsButton.setImage(#imageLiteral(resourceName: "settingsThin").withRenderingMode(.alwaysOriginal), for: .normal)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 3, height: 3)
        settingsButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true

        // Set up gift button
        let mapButton = UIButton(type: .system)
        mapButton.addTarget(self, action: #selector(self.goToSecondMainView), for: .touchUpInside)
        mapButton.setImage(#imageLiteral(resourceName: "secondMainViewIcon").withRenderingMode(.alwaysOriginal), for: .normal)
        mapButton.frame = CGRect(x: 0, y: 0, width: 3, height: 3)
        mapButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        mapButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: mapButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
    }
    
    @objc
    func navSettingsAction() {
        let settingVC = SettingsVC()
        self.navigationController?.pushViewController(settingVC, animated: true)
    }

    @objc
    func goToSecondMainView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.top = 11.0
        layout.sectionInset.bottom = 11.0
        layout.minimumLineSpacing = 22
        layout.scrollDirection = .vertical
        layout.invalidateLayout()
        let secondMainViewCollectionVC = SecondMainCollectionVC(collectionViewLayout: layout)
        self.navigationController?.pushViewController(secondMainViewCollectionVC, animated: true)
    }

    // MARK:- Vibration Alert
    
    // VibAlert: Vibration alert
    private var shouldCheckVibAlertTimer = false
    private var timeOfLastNonDiscovery: Double? = nil
    private let vibAlertTimeInterval = 30.0  // 30 seconds
    private var firstTimeFlagVibAlert = true
    
    private func vibAlertSettingCheck() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: AppSettingKeys.inAppVibSettingBool) != nil {
            shouldVibrateSett = defaults.bool(forKey: AppSettingKeys.inAppVibSettingBool)
        }
    }
    
    private func didNotDiscoverBeacons() {
        shouldCheckVibAlertTimer = true
        
        if timeOfLastNonDiscovery == nil {
            timeOfLastNonDiscovery = Date().timeIntervalSince1970
        }
        
    }
    
    private func didDiscoverBeacons() {
        
        if
            shouldCheckVibAlertTimer,
            timeOfLastNonDiscovery != nil
        {
            
            let nowEpoch = Date().timeIntervalSince1970
            
            if
                (nowEpoch - timeOfLastNonDiscovery!) > vibAlertTimeInterval,
                self.shouldVibrateSett
            {
                // alert vibration
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            shouldCheckVibAlertTimer = false
            timeOfLastNonDiscovery = nil
            return
        }
        
        if
            firstTimeFlagVibAlert,
            self.shouldVibrateSett
        {
            // alert vibration
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            firstTimeFlagVibAlert = false
        }
        
    }

    // MARK:- Update Data

    /*
     Clear all beacons from cache and start sniffing for them again.
     */
    override func pullToRefreshAction(_ sender: Any) {
        // Will delete all beacon data and restart scanning for beacons
        self.userStateManager.restartScanning()

        // FIXME: Stop the updating controller when the updating actually stops
        // Fake stop of update animation
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer: Timer) in
            self.refreshControl.endRefreshing()
        }

    }

    // MARK:- UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !dataForBeacons.isEmpty ? dataForBeacons.count : 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeCollectionViewCell
        cell.setUp(withBeaconData: dataForBeacons[indexPath.row], shouldHandleActionA: true)
        cell.delegate = self
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: AppSize.screenWidth, height: AppSize.homeViewCellHeight)
    }
    
    // MARK:- UICollectionViewDelegate Methods
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK:- UICollectionViewDelegateFlowLayout Methods

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionElementKindSectionHeader { }
        let header = self.collectionView?.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! HeaderViewCell
        self.headerView = header // Keep reference to header view
        if self.dataForBeacons.isEmpty {
            self.headerView.setEmptyDataState()
        }
        else {
            headerView.setPopulatedDataState()
        }
        return header
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if dataForBeacons.count > 0 {
            self.headerView.setPopulatedDataState()
        }
        else {
            self.headerView.setEmptyDataState()
        }
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: AppSize.screenWidth, height: AppSize.headerCellHeight)
    }

    // MARK: - User State Manager Delegate methods

    func userStateManager(_ manager: UserStateManager, userIsNotRegistered titleString: String, infoString: String) {
//        headerTitle = titleString
//        headerSubTitle = infoString
//        // Rreloading view with empty cells
//        dataForBeacons = []
//        collectionView?.reloadData()
    }

    func userStateManager(_ manager: UserStateManager, userIsNotNearBeacons titleString: String, infoString: String) {
        headerTitle = titleString
        headerSubTitle = infoString
        // Rreloading view with empty cells
        dataForBeacons = []
        self.headerView.setEmptyDataState()
        collectionView?.reloadData()
        emptyDataSetText = "There are no beacons near you."
    }

    func userStateManager(_ manager: UserStateManager, updateList dataForBeacons:[DataForBeacon], titleString: String, infoString: String) {
        headerTitle = titleString
        headerSubTitle = infoString
        self.dataForBeacons = []
        self.dataForBeacons = dataForBeacons
        if self.dataForBeacons.isEmpty { self.headerView.setEmptyDataState() }
        collectionView?.reloadData()
        emptyDataSetText = "There are no beacons near you."
    }

    func userStateManager(_ manager: UserStateManager, didGetLocationPermission: Bool) {
        if didGetLocationPermission {
            headerSubTitle = "Select \"Action 1\":"
            emptyDataSetText = "There are no beacons near you."
        }
        else {
            headerSubTitle = "Location Services Needed"
            emptyDataSetText = "Please turn on Location Services from the iPhone's Setting, it's used to find beacons."
        }
        headerTitle = ""
        // Rreloading view with empty cells
        dataForBeacons = []
        collectionView?.reloadData()
    }

    var emptyDataSetText: String = "There are no beacons near you."

    // MARK:-  DZNEmptyDataSetSource and DZNEmptyDataSetDelegate Methods

    override func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let text: String = "Searching..."
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 30.0),
            NSAttributedStringKey.foregroundColor: AppColors.grayFont
        ]

        return NSAttributedString(string: text, attributes: attributes)

    }

    override func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: AppColors.grayFont,
            NSAttributedStringKey.paragraphStyle: paragraph
        ]

        return NSAttributedString(string: self.emptyDataSetText, attributes: attributes)

    }

    func imageAnimation(forEmptyDataSet scrollView: UIScrollView!) -> CAAnimation! {
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 0.75
        pulseAnimation.fromValue = 0.5
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        return pulseAnimation
    }

    func emptyDataSetShouldAnimateImageView(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

    // Button with action when collection view is empty

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: UIColor.black,
        ]

        return NSAttributedString(string: "More Info", attributes: attributes)
    }

    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        Alerts.presentSimple(title: "How This App Works",
                             message: AppDescriptiveText.appDescription, dissmissString: "Ok")
    }

}
