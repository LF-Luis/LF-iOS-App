//
//  SecondMainCollectionVC.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import DZNEmptyDataSet

extension SecondMainCollectionVC: HomeCollectionViewCellDelegate {

    func homeCollectionViewCell(performActionA fromCell: HomeCollectionViewCell) {
        // FOR DEBUGGING PURPOSES ONLY - REMOVE
//        expandCellForActionAHandler = ExpandCellForActionAHandler()
//        expandCellForActionAHandler.expand(withCell: fromCell)
    }

    func homeCollectionViewCell(performActionB fromCell: HomeCollectionViewCell) {
        infoFormVC = InformationFormVC()
        infoFormVC.setUp(withCell: fromCell)
        navigationController?.pushViewController(infoFormVC, animated: true)
    }

}

class SecondMainCollectionVC: BaseCollectionVC {

    var expandCellForActionAHandler: ExpandCellForActionAHandler!
    var infoFormVC: InformationFormVC!

    // Collection vars.
    private var headerView = HeaderViewCell()
    private let cellId = "Cell_2"
    private let headerId = "headerId_2"

    // Beacon data
#if NO_WEB_API_TESTING
// For open source version, allow the use of the app without having a backend set up
// Allow variable to be accessed outside of the class
    var dataForBeacons = [DataForBeacon]()
#else
    private var dataForBeacons = [DataForBeacon]()
#endif

    private var loadingScreen = LFOverlay()

    // MARK:- Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNotifObservers()
        setUpCollectionView()
        navBarSetup()
#if NO_WEB_API_TESTING
// Get and set fake data for testing purposes
        self.runTestNoWebAPI()
        return
#endif
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }

    private func getData() {

        let defaults = UserDefaults.standard
        var shouldUpdateSecondMainViewWithAPIValue = true

        if defaults.object(forKey: AppSettingKeys.shouldUpdateSecondMainViewWithAPI) != nil {
            shouldUpdateSecondMainViewWithAPIValue = defaults.bool(forKey: AppSettingKeys.shouldUpdateSecondMainViewWithAPI)
        }

        if shouldUpdateSecondMainViewWithAPIValue {
            self.reloadDataFromDB()
        }
        else {
            loadingScreen.showOverlay(forView: self.collectionView!, withTitle: nil)
            // Load from local Realm-managed DB
            let realm = try! Realm()
            let realmBcnCData = Array(realm.objects(DataForBeacon.self)) as [DataForBeacon]
            self.dataForBeacons = realmBcnCData
            self.loadingScreen.endOverlay()
            self.collectionView?.reloadData()
            self.loadingScreen.endOverlay()
        }

    }

    private func reloadDataFromDB() {

        if !self.refreshControl.isRefreshing {
            loadingScreen.showOverlay(forView: self.collectionView!, withTitle: nil)
        }

        // Open source edits
        // Parameterize arguments needed to be sent to back end API to get beacon data for this view
        guard let params = ParametrizeForAPI.forSecondMainView() else {
            // Failed to parametrize data for API
            self.loadingScreen.endOverlay()
            self.refreshControl.endRefreshing()
            return
        }

        AzureAPI.forSecondMainView(parameters: params) { (bcnCData: [DataForBeacon]?, err: GetError?) in

            guard let bcnData = bcnCData else {
                self.loadingScreen.endOverlay()
                self.refreshControl.endRefreshing()
                return
            }

            self.dataForBeacons = bcnData

            // Storing data from API call
            // FIXME:
            // Deleting and the re-writing new beacon data values.
            // This is not efficient, but is meant for a quick working prototype.
            // Ideally, this should be updating objects, if any.
            do {
                let realm = try Realm()
                try realm.write { realm.deleteAll() }
                try realm.write { realm.add(bcnData) }
            }
            catch {
                print("Error writing to Realm: \(error).")
            }

            let defaults = UserDefaults.standard
            defaults.set(false, forKey: AppSettingKeys.shouldUpdateSecondMainViewWithAPI)

            self.refreshControl.endRefreshing()
            self.collectionView?.reloadData()
            self.loadingScreen.endOverlay()

        }
    }

    // MARK:- Setup Methods

    private func setUpNotifObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForgound),
                                               name: .UIApplicationWillEnterForeground, object: nil)
    }

    @objc private func willEnterForgound() {
        self.collectionView?.reloadData()
    }

    private func setUpCollectionView() {
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.delegate = self

        // Register cell classes
        self.collectionView!.register(HomeCollectionViewCell.self,
                                      forCellWithReuseIdentifier: cellId)
        self.collectionView?.register(UICollectionViewCell.self,
                                      forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                      withReuseIdentifier: headerId)

        // Set up pull to refresh
        self.setUpPullToRefresh()

    }

    private func navBarSetup() {
        // Set up nav. bar
        navigationItem.title = "2nd Main View"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.shadowImage = UIImage()

//        // Set up Refresh button
//        let refreshButton = UIButton(type: .system)
//        refreshButton.addTarget(self, action: #selector(self.refreshAction), for: .touchUpInside)
//        refreshButton.setImage(#imageLiteral(resourceName: "reload").withRenderingMode(.alwaysOriginal), for: .normal)
//        refreshButton.frame = CGRect(x: 0, y: 0, width: 3, height: 3)
//        refreshButton.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
//        refreshButton.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: refreshButton)
    }


    override func pullToRefreshAction(_ sender: Any) {
        self.reloadDataFromDB()
    }

    // MARK:- UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !dataForBeacons.isEmpty ? dataForBeacons.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomeCollectionViewCell
        cell.setUp(withBeaconData: dataForBeacons[indexPath.row])
        cell.delegate = self
        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: AppSize.screenWidth, height: 180)
    }

}
