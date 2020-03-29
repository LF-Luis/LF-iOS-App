//
//  DataForBeacon.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Realm
import RealmSwift


@objcMembers class DataForBeacon: Object, Decodable {
    /*
     This class holds data belonging to a BLE Beacon. A BLE Beacon has a unique combination of UUID,
     major and minor ID which can be mapped to any type of information.
     The information that can we map to each beacon is shown in this class (i.e. the variables
     below).
     */

    /*
     * This class maps 1:1 to the same class (by a similar name) in the DB. By using Realm
     * (inheriting from Object) we're able to easily store data of this type in the User's iPhone.
     * To be able to Decode directly from a JSON object, Swift's Decodable class is inherit.
     * Note that Object requires that our variables be expoced to Objective-C, thus all the extra
     * work that was done here to make Object (i.e. Realm) and Decodable work together.
     */

    // Current expected JSON structure:
        //    "mainName": Some String Name
        //    "website": http://apple.com/
        //    "bcnPhoneNum": 1234567890
        //    "uuid": 460740c1-...
        //    "imageUrl": https://images.app.goo.gl/LDv2xA7sNQJT6fiN7
        //    "minor": 1
        //    "major": 1
        //    "personGUIId": 35E29000-...
        //    "sampleDate": <null>
        //    "realAddress1": 1234 Barley Field Dr
        //    "metric1": 10
        //    "metric3": 2
        //    "metric2": 9
        //    "didPerformActionA": 1
        //    "shortExtraStr": Short string
        //    "longExtraStr": Long string to explain short string

    // See https://realm.io/docs/swift/latest/    under Property cheatsheet for information on variable declaration
    // Note: All Ints are not optional because Realm requires Int-optional to be of type
    // RealmOptional<Int>(), and that type does not comform to the Codable protocal. By not
    // comforming, "init(from decoder..." cannot decode the value to the type.
    dynamic var mainName: String? = nil
    dynamic var website: String? = nil
    dynamic var shortExtraStr: String? = nil
    dynamic var longExtraStr: String? = nil
    dynamic var bcnPhoneNum: String? = nil
    dynamic var uuid: String? = nil
    dynamic var imageUrl: String? = nil
    dynamic var minor: Int = 0
    dynamic var major: Int = 0
    dynamic var personGUIId: String? = nil
    dynamic var sampleDate: Date? = nil
    dynamic var realAddress: String? = nil
    dynamic var metric1: Int = 0
    dynamic var metric2: Int = 0
    dynamic var metric3: Int = 0
    dynamic var didPerformActionA: Bool = false

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        mainName = try? container.decode(String.self, forKey: .mainName)
        website = try? container.decode(String.self, forKey: .website)
        shortExtraStr = try? container.decode(String.self, forKey: .shortExtraStr)
        longExtraStr = try? container.decode(String.self, forKey: .longExtraStr)
        bcnPhoneNum = try? container.decode(String.self, forKey: .bcnPhoneNum)
        uuid = try? container.decode(String.self, forKey: .uuid)
        imageUrl = try? container.decode(String.self, forKey: .imageUrl)
        minor = try container.decode(Int.self, forKey: .minor)
        major = try container.decode(Int.self, forKey: .major)
        personGUIId = try? container.decode(String.self, forKey: .personGUIId)
        sampleDate = try? container.decode(Date.self, forKey: .sampleDate)
        realAddress = try? container.decode(String.self, forKey: .realAddress)
        metric1 = try container.decode(Int.self, forKey: .metric1)
        metric2 = try container.decode(Int.self, forKey: .metric2)
        metric3 = try container.decode(Int.self, forKey: .metric3)
        didPerformActionA = try container.decode(Bool.self, forKey: .didPerformActionA)
        super.init()
        
    }

//    override static func primaryKey() -> String? {
//        return "mainName"
//    }

    required init() {
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    private enum CodingKeys: String, CodingKey {
        case mainName
        case website
        case bcnPhoneNum
        case uuid
        case imageUrl
        case minor
        case major
        case personGUIId
        case sampleDate
        case realAddress = "realAddress1"
        case didPerformActionA
        case metric1
        case metric2
        case metric3
        case shortExtraStr
        case longExtraStr
    }

}


