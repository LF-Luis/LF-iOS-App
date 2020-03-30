//
//  UserState.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/*
 This class (UserStateManager) and protocal (UserStateManagerDelegate) are meant to manage the
 session of a User using the app.
 The methods in UserStateManagerDelegate define the various actions that UserStateManager may take
 during the session of a User.
 */

protocol UserStateManagerDelegate: class {
    /*
     There are four main stages that rule the User State:
     - userIsNotRegistered: User is not registered, they should be prompted to register. The rest
     of the states will not be called unless this one is resolved.
     - userIsNotNearBeacons: User is not near beacons.
     - updateList: triggered when UserStateManager is ready to update the list of beacon objects
     discovered
     - didGetLocationPermission: triggered by UserStateManager when location permission has been
     changed (i.e. either granted or removed)
        - Note that location permission is needed to use BLE iBeacons
    */

    func userStateManager(_ manager: UserStateManager, userIsNotRegistered titleString: String, infoString: String)
    func userStateManager(_ manager: UserStateManager, userIsNotNearBeacons titleString: String, infoString: String)
    func userStateManager(_ manager: UserStateManager, updateList dataForBeacons:[DataForBeacon], titleString: String, infoString: String)
    func userStateManager(_ manager: UserStateManager, didGetLocationPermission: Bool)

}

enum UserSate {
    case noLocationPermission, notRegistered, notNearBeacons, nearBeacons //, gotLocationPermission
}

extension UserStateManager {
    // class' APIs

    /*
     Cancel status set by  Action A
     The User will first be prompted by a dialog box to make sure this what they want to do.
     If User agrees to go ahead and cancel Action A, this function will attempt to cancel via the AzureAPI class.
     Completion of this function "didSucceed" should inform if in the backend Action A was cancelled.
     */
    class func cancelActionA(ofDataBeacon bcr: DataForBeacon,
                             presentedOnVC vC: UIViewController? = nil,
                             withActionAButtonReselected reselected: Bool = true,
                             _ completion:@escaping (_ didSucceed: Bool) -> Void)
    {
        var message: String = ""
        if reselected {
            message = "Action A has already been selected.\n\nDo you wish to cancel this?"
        }
        else {
            message = "Are you sure you want to cancel your Action A?"
        }

        // Ask User if they are sure they want to cancel Action A
        Alerts.present(title: "Project", message: message, completionString: "Yes", cancelString: "No", withController: vC) {

// Testing without using web APIs
#if NO_WEB_API_TESTING
            /* *****************************************************************************/
            // This snipped of code comes from the "didSucceed" AzureAPI call below
            completion(true)
            return
            /* *****************************************************************************/
#endif

            // User decided to cancel Action A for this cell
            // Parametrize data for API
            guard let paramData = ParametrizeForAPI.cancelActionA(withDataForBcn: bcr) else {
                // Failed to parametrized data.
                Alerts.presentSimple(title: "Project", message: "Something went wrong with this request, please try again.", dissmissString: "Ok")
                completion(false)
                return
            }

            // Call API
            AzureAPI.postCancelActionA(parameters: paramData) { (didSucceed: Bool) in
                if didSucceed {
                    completion(true)
                    return
                }
                else {
                    Alerts.presentSimple(title: "Project", message: "Something went wrong with this request, please try again.", dissmissString: "Ok")
                    completion(false)
                    return
                }
            }

        }
    }

}

class UserStateManager: NSObject, BeaconManagerDelegate, NSCacheDelegate {
    /*
     * This class is specifically made to deal with how a User will use the Action A feature. It
     * wraps various functionalities (such as BLE beacon detection, API calls, and User info getting)
     * This class should morph as the complexity of the app grows (i.e. more Actions are added).
     */

    weak var delegate: UserStateManagerDelegate?
    private var mainUser = MainUser()
    private var userState = UserSate.noLocationPermission
    private var beaconManager: BeaconManager!

    var fakeCache = Dictionary<String, DataForBeacon>()

    // FIXME: Implement; ignore beacons that have no data
    // I.e. do not make an API GET call over-and-over again for beacons with no data
    //    private var allUniqueIdsArr = [String]()
    // This array holds every UUID discovered, even those that belong to our company, but that currently have no data linked to it
    // The reason to also hold those that do not have data linked to it is so that the API call is not constantly called just to figure out there is not data linked to that beacon.
    // Holds current BeaconData to be displayed. The UUID keys are held in beaconIDArr
#if NO_BEACON_TESTING || NO_WEB_API_TESTING
    var dispUniqueIdDataDisplay = Dictionary<String, DataForBeacon>()
#else
    private var dispUniqueIdDataDisplay = Dictionary<String, DataForBeacon>()
#endif
    private var beaconIDSet = Set<String>()   // This is used to make sure no duplicate keys exist. When didConnectToBeacons finds that a certain UUID should be displayed, it is added to this set. Works together with beaconIDArr.
    private var dispBeaconIDArr = [String]()  // The Collection View Delegate methods require an index to display a cell or access data from a cell. For this reason, at the end of didConnectToBeacons, when BeaconData is succesfully retrieved, beaconIDSet is converted to beaconIDArr. Works together with beaconIDSet.

    override init() {
        super.init()
        userState = .notNearBeacons
        let infoStr = ""
        let actionStr = "Action String"

        // FIXME: There's a good reason why I made this run asynchronously, but at the time of
        // writting this comment I forgot. Fix this by taking it out of the async wrapper and
        // testing whether it breaks (then leave a better comment).
#if !NO_WEB_API_TESTING
// Without this, after loading fake data, the data gets blown away because this guy is running on a
// seperate thread that is not the main UI thread
        DispatchQueue.main.async {
            self.delegate?.userStateManager(self, userIsNotNearBeacons: infoStr, infoString: actionStr)
        }
#endif

        beaconManager = BeaconManager(withFetchTimeInterval: 10)
        beaconManager.delegate = self
    }


    func stopScanning() {
        beaconManager = BeaconManager()
        beaconManager.delegate = nil
    }

    /**
     This function is made especifically for updating the HomeCollectionVC's collection view.
     The beacons listed in [DataForBeacon] will be removed from cache, then the beaconManager
     will start sniffing for beacons again and find the beacons whose DataForBeacon was
     removed from cache. Since they are no longer in cache, these beacons will call the API again,
     thus "updating" the HomeCollectionVC's collection view.
     */
    func restartScanning() {

        self.dispBeaconIDArr.removeAll()
        self.dispBeaconIDArr = [String]()

        // Remove from dictonary that uses key
        self.dispUniqueIdDataDisplay.removeAll()
        self.dispUniqueIdDataDisplay = Dictionary<String, DataForBeacon>()

        // Remove value from fake cache
        self.fakeCache.removeAll()
        self.fakeCache = Dictionary<String, DataForBeacon>()

        /*
         dispBeaconIDArr is being cleared because the key for the delBcns is there.
         dispBeaconIDArr is used to not constantly update the collection view, but since this
         function is being called to update the main collection view, it can be cleared.
         */
        //        self.dispBeaconIDArr = [String]()

        // Re-start beacon sniffing
        self.beaconManager.enterScanning()
    }

    /*
     * This function automatically updates the information in mainUser variable.
     * Any class using this UserState object should call this function after changes have been made
     * to the User's info in the device
     */
    func getUserInfo() {
        let userVals = mainUser.getValues()

        // If mainUser info has not been set yet, then the delegator will be notified
        // If mainUser.getValues() does not return nil, throughout the rest of this class there is
        // no need for nil-checking anymore for mainUser.
        if userVals == nil && userState != .notRegistered {
            userState = .notRegistered
            let notRegisterStr = ""
            let notRegisterActStr = ""
            delegate?.userStateManager(self, userIsNotRegistered: notRegisterStr, infoString: notRegisterActStr)
        }

    }

    // MARK: - Beacon Manager Delegate Methods

    func didGetLocationPermission(_ manager: BeaconManager, didSucceed: Bool) {

        guard let delegate = self.delegate else {
            print("Error: UserStateManager.didGetLocationPermission, failed to get delegate.")
            return;
        }

        if didSucceed {
            delegate.userStateManager(self, didGetLocationPermission: true)
            return;
        }

        // Failed to get location

        // Set data to empty and reload
        delegate.userStateManager(self, didGetLocationPermission: false)

        // Present Alert telling User to turn on Location Services

        let titleString = "Project"
        let msgString = "Please turn on Location Services, it's used to find beacons."

        guard
            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl)
            else {
                Alerts.presentSimple(title: titleString, message: msgString, dissmissString: "Ok")
                return;
        }

        Alerts.present(title: titleString, message: msgString, completionString: "Go To Settings") {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (didSucceed: Bool) in
                if !didSucceed {
                    Alerts.presentSimple(title: titleString, message: msgString, dissmissString: "Ok")
                }
            })
        }

    }

    func noConnectionMadeToBeacons(_ manager: BeaconManager) {
        dispUniqueIdDataDisplay = Dictionary<String, DataForBeacon>()
        dispBeaconIDArr = [String]()
        delegate?.userStateManager(self, userIsNotNearBeacons: "No connection to beacons", infoString: "No connection to beacons")
    }

    // FIXME: Return hash of string instead.
    func makeDictKey(fromBeacon beacon: CLBeacon) -> String {
        let text = beacon.proximityUUID.uuidString + "," + beacon.major.stringValue + "," + beacon.minor.stringValue
        return text
    }

    // FIXME: Return hash of string instead.
    func makeDictKey(fromBeacon bcn: DataForBeacon) -> String {
        let bcnUUID = bcn.uuid ?? ""
        let text = bcnUUID.uppercased() + "," + String(bcn.major) + "," + String(bcn.minor)
        return text
    }

    func didConnectToBeacons(_ manager: BeaconManager, beacons: [CLBeacon]) {
        // If any of the following "checks" make shouldReloadData True, then beacon data in list
        // view will be reloaded

        print("(UserStateManager) All Beacons-----------")
        for beacon in beacons {
            print(beacon.proximityUUID.uuidString)
            print(beacon.major.stringValue)
            print(beacon.minor.stringValue)
        }
        print("------------------------------------------")

        if beacons.isEmpty && !dispUniqueIdDataDisplay.isEmpty {
            let emptyBeaconsData = [DataForBeacon]()
            let emptyInfoString = "Select Action A below:"
            self.delegate?.userStateManager(self, updateList: emptyBeaconsData,
                                            titleString: "", infoString: emptyInfoString)
        }

        // Check #1
        // check if there are more/less nearBeacons than before
        var shouldReloadData: Bool = ( beacons.count != dispUniqueIdDataDisplay.count )

        // Check #2
        // checks if different beacons have been added other than the ones being displayed at the
        // moment
        if !shouldReloadData {
            for beacon in beacons {
                let tempKey = makeDictKey(fromBeacon: beacon)
                if !dispBeaconIDArr.contains(tempKey) {
                    // I.e. beacons being displayed (dispBeaconIDArr) do not contain one of the
                    // beacons just discovered
                    shouldReloadData = true
                    break
                }
            }
        }

        if shouldReloadData {
            // Reloading the data sets that hold the data that will be displayed.
            // This may mean new GET calls and getting objects that have been cached.
            dispUniqueIdDataDisplay = Dictionary<String, DataForBeacon>()
            dispBeaconIDArr = [String]()

            var beaconsToGetFromAPI = [CLBeacon]()

            for beacon in beacons {
                let key = makeDictKey(fromBeacon: beacon)

                if let cachedVersion = self.fakeCache[key] {
                    // Retrieve beacon data that has been cached
                    // Note: If there are two beacons with the same major/minor combination, due to
                    // the use of a key of maj/min, only one instance will show on the User's screen.
                    print("Retrieving from cache: \(key)")
                    dispUniqueIdDataDisplay[key] = cachedVersion
                }
                else {
                    // by storing it here, you will eventually get this value from an API call
                    beaconsToGetFromAPI.append(beacon)
                }
            }

            if beaconsToGetFromAPI.isEmpty {
                // No beacons needed to get from API-get call, update beacons being displadey with
                // beacons gathered from cache.
                self.updateBeaconDataList()
                return;
            }

            guard let (params, initialSet) = ParametrizeForAPI.getBeaconsData(withCLBeacons: beaconsToGetFromAPI) else {
                print("Failed to parameterize data or only beacon(s) that have been black-listed were going to be used in API call.")
                // No beacons needed to get from API-get call, update beacons being displadey with
                // beacons gathered from cache.
                self.updateBeaconDataList()
                return;
            }

            // Beacon data has not been cached, get it from Azure web API
            AzureAPI.getBeaconsData(parameters: params, initalSetOfBeacons: initialSet) {
                (beaconDataResult: [DataForBeacon]?, getErr: GetError?) in

                guard let bcnDataRes = beaconDataResult else {
                    print("UserStateManager.didConnectToBeacons(...) Was called to update but API returned nil data.")
                    // Complete with cached data only
                    self.updateBeaconDataList()
                    return;
                }

                for bcn in bcnDataRes {
                    let key = self.makeDictKey(fromBeacon: bcn)
                    print("Storing cache: \(key)")
                    self.fakeCache[key] = bcn
                    self.dispUniqueIdDataDisplay[key] = bcn
                }

                // Complete with all cached and API-get baeacon data
                self.updateBeaconDataList()
                return;

            }

        }

    }

    #if NO_BEACON_TESTING || NO_WEB_API_TESTING
    func testWrapper_updateBeaconDataList() {
        self.updateBeaconDataList()
    }
    #endif

    private func updateBeaconDataList() {
        self.dispBeaconIDArr = Array(self.dispUniqueIdDataDisplay.keys)

        // Update informative text
        let titleStr = ""
        let infoStr = "Select Action A below:"

        var beaconsData = [DataForBeacon]()

        for bId in self.dispBeaconIDArr {
            beaconsData.append(self.dispUniqueIdDataDisplay[bId]!)
        }

        self.delegate?.userStateManager(self, updateList: beaconsData,
                                        titleString: titleStr, infoString: infoStr)

        return

    }

    /**
     Clear cache of this class and cache collected from HomeCollectionViewCell
     */
    func clearCachedData() {
        // Clearing cache from Home Collection cells
        HomeCollectionViewCell.clearCachedData()

        // Clearing cache held by this class
        self.fakeCache.removeAll()
        self.fakeCache = Dictionary<String, DataForBeacon>()
    }

}

