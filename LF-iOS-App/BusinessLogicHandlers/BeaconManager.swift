//
//  BLEBeacon.swift
//  ServiceQueue
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import CoreLocation

/*
 Purpose:
 The protocal and class in this file are used to handle the iOS app working with a BLE beacon.

 Usage:
 This class is currently being used in BusinessLogicHandlers/UserStateManager.swift
 The UserStateManager class subscribes to the BeaconManagerDelegate protocal to act upon different
 actions that BeaconManager may trigger if a beacon is within range.

 Apple's CoreLocation can only track about 15 UUID. To learn more about a beacon's UUID, major and
 minor number see: https://support.kontakt.io/hc/en-gb/articles/201620741-iBeacon-Parameters-UUID-Major-and-Minor
 In this app, to set the UUID to use go to the AppInfo/AppKey.swift and in the BeaconeUUID struct
 append to its "uuids" array.
 */

protocol BeaconManagerDelegate: class {
    /*
     * This protocal will be used to deal with the main four activities we care about w.r.t. the
     * beacon action.
     *
     * - noConnectionMadeToBeacons(...) should be called as soon as the class subscribing to this
     *   protocal has been initiated. It is stating that no beacon has been found yet.
     * - didConnectToBeacons(...) called when a beacon has been found.
     * - didGetLocationPermission(...) called when location permission from User is gathered.
    */
    
    // Beacon recognition life-cycle
    func noConnectionMadeToBeacons(_ manager: BeaconManager)
    func didConnectToBeacons(_ manager: BeaconManager, beacons: [CLBeacon])

    // User location permission (this needs to succeed before beacon recognition life-cycle can start
    func didGetLocationPermission(_ manager: BeaconManager, didSucceed: Bool)

}

class BeaconManager: NSObject, CLLocationManagerDelegate {
    /*
     * This class is meant to discover BLE beacons supported by the app, and seamlessly report back
     * to who ever subscribes to BeaconManagerDelegate.
     */
    
    weak var delegate: BeaconManagerDelegate?
    private var locationManager: CLLocationManager!
    
    // Time interval in seconds to fetch beacon data
    private var fetchTimeInterval: Double = 1.0
    private var updateTimer: Timer!
    private var shouldUpdateBeacons = true
    
    init(withFetchTimeInterval fTI: Double = 1) {
        super.init()
        fetchTimeInterval = fTI
        delegate?.noConnectionMadeToBeacons(self)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        enterScanning()
    }

    func enterScanning(withRequestForAuthorization reqAuth: Bool = true) {
        locationManager.requestWhenInUseAuthorization()
    }

    /**
     Warning: If authorization has not been given before, this function will fail.
     This function will kick off the "startScanning()" function.
     */
    func hardKickOffScanning() {
        self.shouldUpdateBeacons = true
        self.startScanning()
    }

    private func startScanning() {
        locationManager.startMonitoring(forRegions: BeaconeUUID().regions)
        locationManager.startRangingBeacons(inRegions: BeaconeUUID().regions)
        // Set-up of timer which will dictate when beacons fetched are used
        updateTimer = Timer.scheduledTimer(timeInterval: fetchTimeInterval, target: self,
                                           selector: #selector(updateTimerFlag),
                                           userInfo: nil, repeats: true)
    }
    
    // MARK: - Timer methods
    @objc private func updateTimerFlag() {
        shouldUpdateBeacons = true
    }
    
    // MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        guard let delegate = delegate else {
            print("Error (BeaconManager): delegate not set in func locationManager(..., didChangeAuthorization...)")
            return
        }

        switch status {
//        case .restricted, .denied, .notDetermined:
//            delegate.didGetLocationPermission(self, didSucceed: false)
        case .authorizedWhenInUse:
            if
                CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
                CLLocationManager.isRangingAvailable()
            {
                delegate.didGetLocationPermission(self, didSucceed: true)
                self.startScanning()
            }
            else {
                delegate.didGetLocationPermission(self, didSucceed: false)
            }
        case .notDetermined:
            print("(BeaconManager): location status not yet determined.")
            return
        default:
            print("Error (BeaconManager): unknown location status was given.")
            delegate.didGetLocationPermission(self, didSucceed: false)
            return
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon],
                         in region: CLBeaconRegion) {
        
        // Only return beacons found when shouldUpdateBeacons is true, which is based on
        // self.fetchTimeInterval
        if !shouldUpdateBeacons {
            return
        }
        
        shouldUpdateBeacons = false

        if !beacons.isEmpty {
            delegate?.didConnectToBeacons(self, beacons: beacons)
//            self.printBeaconDebugData(beacons: beacons)
        }
        else {
            delegate?.noConnectionMadeToBeacons(self)
        }
    }

    private func printBeaconDebugData(beacons: [CLBeacon]) {
        print("------------ Beacons Discovered ------------")
        for bc in beacons {
            
            var proximity = ""
            switch bc.proximity {
            case .near:
                proximity = "near"
                break
            case .immediate:
                proximity = "immediate"
                break
            case .far:
                proximity = "far"
                break
            case .unknown:
                proximity = "unknown"
                break
            default:
                print("none")
                break
            }
            
            print("----- Beacon -----")
            print("uuid: ", bc.proximityUUID.uuidString)
            print("minor: ", bc.minor.stringValue)
            print("major: ", bc.major.stringValue)
            print("proximity: ", proximity)
            print("bc.accuracy: ", bc.accuracy)
            print("bc.rssi: ", bc.rssi)
            print("------------------")
            
        }
        print("--------------------------------------------")
    }
    
}
