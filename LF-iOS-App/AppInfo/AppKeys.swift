//
//  LFKeys.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import CoreLocation

/*
 Important App keys. DO NOT edit unless you know what you are doing.
 */

struct AppSettingKeys {
    // App settings to persist
    static let inAppVibSettingBool: String = "inAppVibSettingBool"

    // To store User's info
    static let firstName: String = "firstName"
    static let lastName: String = "lastName"
    static let phoneNumber: String = "phoneNumber"
    static let gUUID: String = "gUUID"

    // TODO: Remove usage of this key
    // Key to check if visited locations should be updated
    static let shouldUpdateSecondMainViewWithAPI: String = "shouldUpdateSecondMainView"

    // Verification code used during the registration process
    static let verificationCode: String = "verificationCode"
}


extension Notification.Name {
    static let didFinishRegister = Notification.Name("didFinishRegister")
    static let didLogOut = Notification.Name("didLogOut")
}

struct BeaconeUUID {
    static let uuids: [UUID] = [
        UUID(uuidString: "replace-this-with-uuid-number")!
    ]

    var regions = Set<CLBeaconRegion>()

    init() {
        for uuid in BeaconeUUID.uuids {
            regions.insert(CLBeaconRegion(proximityUUID: uuid, identifier: uuid.uuidString))
        }
    }
}
