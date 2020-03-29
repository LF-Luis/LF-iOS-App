//
//  ParametrizeForAPI.swift
//  ServiceQueue
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//


import UIKit
import CoreLocation

class ParametrizeForAPI: NSObject {

    // This black list is populated when the getBeaconsData info API is called. It's populated with
    // beacons that are not currently being serviced. We do not store this (i.e. Realm) on the
    // iPhone permanently so that if next time the User opens the app, this list can be repopulated
    static var blacklistedBeacons = Set<String>()

    /*
     * Parameterize data for the register API found in AzureAPI class
     * Returns: If successful, returns parameterized data,
     * else (fails) returns nil.
     *
     * E.g. of parameterized data
     *  "FName": "Joe"
     *  "LName": "Smith"
     *  "CountryCode" : +1 (by default)
     *  "PhoneNum": "1234567890"
     */
    class func register(
        firstName: String,
        lastName: String,
        phoneNumber: String) -> [String: AnyObject]?
    {

        let parameters: [String: AnyObject] = [
            "FName" : firstName as AnyObject,
            "LName" : lastName as AnyObject,
            "CountryCode" : "1" as AnyObject,
            "PhoneNum" : phoneNumber as AnyObject
        ]

        return parameters

    }

    class func verifyRegistration(oneTimePasscode oTP: String, verificationCode: String)
        -> [String: AnyObject]?
    {

        let mainUser = MainUser()

        guard let (firstName, lastName, phoneNumber) = mainUser.getValues() else {
            return nil
        }

        let parameters: [String: AnyObject] = [
            "OTPNum" : oTP as AnyObject,
            "Code" : verificationCode as AnyObject,
            "FName" : firstName as AnyObject,
            "LName" : lastName as AnyObject,
            "CountryCode" : "1" as AnyObject,
            "PhoneNum" : phoneNumber as AnyObject
        ]

        return parameters

    }

    /*
     Parametrize data for the Action A API found in AzureAPI class
     */
    class func actionA(withDataForBcn dataForBeacon: DataForBeacon) -> [String: AnyObject]? {

        let mU = MainUser()
        guard let personUuid: String = mU.getGUIID() else {
            return nil
        }

        if dataForBeacon.minor == 0 { return nil }
        if dataForBeacon.minor == 0 { return nil }

        guard let uuidStr: String = dataForBeacon.uuid else {
            return nil
        }

        let parameters: [String: AnyObject] = [
            "PersonGUIId" : personUuid as AnyObject,
            "UUID" : uuidStr as AnyObject,
            "Major" : dataForBeacon.major as AnyObject,
            "Minor" : dataForBeacon.minor as AnyObject
        ]

        return parameters

    }

    /**
     Parametrize data to cancel Action A API found in AzureAPI class
     */
    class func cancelActionA(withDataForBcn dataForBeacon: DataForBeacon) -> [String: AnyObject]? {
        return ParametrizeForAPI.actionA(withDataForBcn: dataForBeacon)
    }

    /*
     * Assembles parameters for "getBeaconsData" API
     * Arguments:
     *  - withCLBeacons: [CLBeacon]
     * Returns: Parametrize data, or nil if data could not be assembled. If data is assembled
     *  successfully, it loks as follows:
     *  [
     *      "PersonGUIId": "123456...",
     *      "BeaconList": "[ ["UUID": "12...","Major": "1", "Minor": "2],
     *                  ["UUID": "12...","Major": "1", "Minor": "2], ... ]"
     *  ]
     */
    class func getBeaconsData(withCLBeacons bcns: [CLBeacon]) -> ([String: AnyObject], Set<String>)? {
        let mU = MainUser()
        guard let personUuid: String = mU.getGUIID() else {
            return nil
        }

        var listOfBeaconsData = Array<[String: AnyObject]>()
        var majMinKeys = Set<String>()

        for bcn in bcns {
            // only append beacons that could be parametrized and have not been blacklisted
            if let (beaconData, key) = ParametrizeForAPI.beaconData(withCLBeacon: bcn) {
                listOfBeaconsData.append(beaconData)
                majMinKeys.insert(key)
            }
        }

        if listOfBeaconsData.isEmpty {
            // Either no beacon could be parametrized or all of them were in the blacklist
            return nil
        }

        let parameters: [String: AnyObject] = [
            "PersonGUIId" : personUuid as AnyObject,
            "BeaconList" : listOfBeaconsData as AnyObject
        ]

        return (parameters, majMinKeys)

    }

    /*
     * This function takes as argument a single CL beacon and returns the following organized
     * data set:
     *  [
     *      "UUID": "1234-1234-1234-12344...",
     *      "Major": "1",
     *      "Minor": "2
     *  ]
     */
    private class func beaconData(withCLBeacon bcn: CLBeacon) -> ([String: AnyObject], String)? {

        if
            bcn.minor.stringValue.isEmpty ||
            bcn.major.stringValue.isEmpty ||
            bcn.proximityUUID.uuidString.isEmpty
        {
            return nil
        }

        let key = majMinKey(major: bcn.major, minor: bcn.minor)

        // if the beacon being revised has been backlisted, return nil
        if ParametrizeForAPI.blacklistedBeacons.contains(key) {
            return nil
        }

        let parameters: [String: AnyObject] = [
            "UUID" : bcn.proximityUUID.uuidString as AnyObject,
            "Major" : bcn.major as AnyObject,
            "Minor" : bcn.minor as AnyObject
        ]

        return (parameters, key)

    }

    /**
     Input major and minor, returns those values as a key.
     E.g.: major: 1, minor: 2 -> "1,2"
     Tested with Int, NSNumber, String
     */
    class func majMinKey<T>(major: T, minor: T) -> String {
        return String("\(major),\(minor)")
    }

    /**
     Returns personal user id
     */
    class func forSecondMainView() -> [String: AnyObject]? {

        let mU = MainUser()
        guard let personUuid: String = mU.getGUIID() else {
            return nil
        }

        let parameters: [String: AnyObject] = [
            "PersonGUIId" : personUuid as AnyObject
        ]

        return parameters

    }

}



