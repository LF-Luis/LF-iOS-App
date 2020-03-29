//
//  UserTesting.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation

// MARK: - Public Facing Test API

#if NO_BEACON_TESTING
//extension UserStateManager {
//    func runTestNoBeacons() {
//        // Make the BeaconManager stop sniffing for beacons
//        self.stopScanning()
//        let userTesting = UserTesting()
//        if userTesting.shouldRunTestAPI() {
//            // call web API and load beacon data
//            self.testLoadBeaconsWithData()
//        }
//    }
//}
#endif

#if NO_BEACON_TESTING

// MARK: - File Private Test APIs


extension UserStateManager {

    fileprivate func testLoadBeaconsWithData() {

        let userTesting = UserTesting()

        guard let (parData, stringKey) = userTesting.assembleFakeInputAPIData() else {
            Alerts.presentSimple(title: "App Test", message: "Failed to parametrize test data", dissmissString: "OK")
            return
        }

        AzureAPI.getBeaconsData(parameters: parData, initalSetOfBeacons: stringKey) {
            (beaconDataResult: [DataForBeacon]?, getErr: GetError?) in

            guard let bcnDataRes = beaconDataResult else {
                print("UserStateManager.didConnectToBeacons(...) Was called to update but API returned nil data.")

                return
            }

            for bcn in bcnDataRes {
                let key = NSString(string: self.makeDictKey(fromBeacon: bcn))
                self.dispUniqueIdDataDisplay[key as String] = bcn
            }

            self.testWrapper_updateBeaconDataList()

        }
    }

}

fileprivate struct TestBeaconData {
    var uuid: String
    var major: String
    var minor: String
}

fileprivate class UserTesting: NSObject {

    let testAPICountKey: String = "testAPICountKey"

    /**
     Returns parametrized data for API call
     */
    func assembleFakeInputAPIData() -> ([String: AnyObject], Set<String>)? {

        // Get UUID
        guard let uuidFirst = BeaconeUUID().regions.first?.proximityUUID.uuidString else {
            Alerts.presentSimple(title: "App - TEST", message: "Cannot load app's UUID", dissmissString: "Ok")
            return nil
        }

        let testBeacon1 = TestBeaconData(uuid: uuidFirst, major: "1", minor: "4")
        let testBeacon2 = TestBeaconData(uuid: uuidFirst, major: "1", minor: "5")

        // Note, this may be returning nil
        return ParametrizeForAPI.testGetBeaconsData(withCLBeacons: [testBeacon1, testBeacon2])

    }


    func shouldRunTestAPI() -> Bool {

        let defaults = UserDefaults.standard

        if defaults.object(forKey: self.testAPICountKey) == nil {
            defaults.set(1, forKey: self.testAPICountKey)
        }
        else {
            var tempCount = defaults.integer(forKey: self.testAPICountKey)
            tempCount = tempCount + 1
            defaults.set(tempCount, forKey: self.testAPICountKey)
        }

        let apiCount = defaults.integer(forKey: self.testAPICountKey)

        if apiCount > 3 {
            return false
        }
        else {
            return true
        }

    }


}



fileprivate extension ParametrizeForAPI {

    /**
     * Assembles parameters for "getBeaconsData" API
     * Arguments:
     *  - withCLBeacons: [TestBeaconData]
     * Returns: Parametrize data, or nil if data could not be assembled. If data is assembled
     *  successfully, it loks as follows:
     *  [
     *      "PersonGUIId": "123456...",
     *      "BeaconList": "[ ["UUID": "12...","Major": "1", "Minor": "2],
     *                  ["UUID": "12...","Major": "1", "Minor": "2], ... ]"
     *  ]
     */
    class func testGetBeaconsData(withCLBeacons bcns: [TestBeaconData]) -> ([String: AnyObject], Set<String>)? {
        let mU = MainUser()
        guard let personUuid: String = mU.getGUIID() else {
            return nil
        }

        var listOfBeaconsData = Array<[String: AnyObject]>()
        var majMinKeys = Set<String>()

        for bcn in bcns {
            let (beaconData, key) = ParametrizeForAPI.testBeaconData(withCLBeacon: bcn)
            listOfBeaconsData.append(beaconData)
            majMinKeys.insert(key)
        }

        let parameters: [String: AnyObject] = [
            "PersonGUIId" : personUuid as AnyObject,
            "BeaconList" : listOfBeaconsData as AnyObject
        ]

        return (parameters, majMinKeys)

    }

    /**
     * This function takes as argument a single CL beacon and returns the following organized
     * data set:
     *  [
     *      "UUID": "1234-1234-1234-12344...",
     *      "Major": "1",
     *      "Minor": "2
     *  ]
     */
    private class func testBeaconData(withCLBeacon bcn: TestBeaconData) -> ([String: AnyObject], String) {

        let parameters: [String: AnyObject] = [
            "UUID" : bcn.uuid as AnyObject,
            "Major" : bcn.major as AnyObject,
            "Minor" : bcn.minor as AnyObject
        ]

        return (parameters, ParametrizeForAPI.majMinKey(major: bcn.major, minor: bcn.minor))

    }

}

#endif
