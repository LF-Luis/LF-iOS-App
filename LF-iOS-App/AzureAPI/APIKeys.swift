//
//  APIKeys.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation

/*
 Important Azure API keys and API end-points.
 DO NOT edit unless you know what you are doing.
 */

struct AzureAPIKeys {
    // A few sample API keys for open source version of iOS app
    static let baseUrl: String = "http://some_service.azurewebsites.net/"
    static let APPId: String = "123"
    static let APIKey: String = "123"
}

struct APIEndPoints {

    // A few sample API endpoints for open source version of iOS app
    static let actionA: String = "api/ActionA"
    static let cancelActionA: String = "api/CancelActionA"
    static let forSecondMainView: String = "api/forSecondMainView"
    static let getBeaconInfo: String = "api/GetBeaconInfo"
    static let register: String = "api/Register"
    static let verify: String = "api/Verify"

}
