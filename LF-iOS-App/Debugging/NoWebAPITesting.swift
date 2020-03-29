//
//  NoWebAPITesting.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation

// MARK: - Public Facing Test API

#if NO_WEB_API_TESTING
extension UserStateManager {
    func runTestNoWebAPI() {
        // Make the BeaconManager stop sniffing for beacons
        self.stopScanning()

        // Get hardcoded beacon data
        let fakeData = NoWebAPITestingHelper.createFakeBeaconData()

        for data in fakeData {
            self.dispUniqueIdDataDisplay[data.key] = data.value
        }

        // Update HomeCollectionView UI
        self.testWrapper_updateBeaconDataList()

    }
}

extension SecondMainCollectionVC {
    func runTestNoWebAPI() {

        // Get and set hardcoded beacon data
        self.dataForBeacons = Array(NoWebAPITestingHelper.createFakeBeaconData().values) as [DataForBeacon]

        // Reload collection view data
        self.collectionView?.reloadData()

    }
}
#endif

#if NO_WEB_API_TESTING

// MARK: - File Private Test APIs

fileprivate class NoWebAPITestingHelper: NSObject {

    class func createFakeBeaconData() -> Dictionary<String, DataForBeacon> {

        // We'll create a few fake DataForBeacon objects

        // 1
        let dataForBeacon_1 = DataForBeacon()
        dataForBeacon_1.mainName = "Test Name 1"
        dataForBeacon_1.imageUrl = "https://cdn.cnn.com/cnnnext/dam/assets/180110171911-new-york-skyline-large-169.jpg"
        dataForBeacon_1.metric1 = 5
        dataForBeacon_1.didPerformActionA = true
        dataForBeacon_1.metric2 = 20
        dataForBeacon_1.metric3 = 4
        dataForBeacon_1.shortExtraStr = "There's more"
        dataForBeacon_1.longExtraStr = "There's more information here about the text in front of the cell."

        // 2
        let dataForBeacon_2 = DataForBeacon()
        dataForBeacon_2.mainName = "Test Name 2 Long Name That Must be Wrapped By the app hopefully And Hopefully no name will ever be this long"
        dataForBeacon_2.imageUrl = "https://res.cloudinary.com/maa/image/upload/c_lfill,g_auto,f_auto,q_auto:eco,h_1252,w_2160/v1/maac/-/media/images/metro-landing-page-heros/austin_tx.jpg"
        dataForBeacon_2.metric1 = 7
        dataForBeacon_2.didPerformActionA = false
        dataForBeacon_2.metric2 = 15
        dataForBeacon_2.metric3 = 2
        dataForBeacon_2.shortExtraStr = "Short String"

        // 3
        let dataForBeacon_3 = DataForBeacon()
        dataForBeacon_3.mainName = "Test Name 3"
        dataForBeacon_3.imageUrl = "https://cdn.vox-cdn.com/thumbor/3EceI7N2wWGcvtiGGEYDrmI7Az4=/0x0:2560x1430/1200x800/filters:focal(1076x511:1484x919)/cdn.vox-cdn.com/uploads/chorus_image/image/66553721/dronechinatown_lede.0.jpg"
        dataForBeacon_3.metric1 = 7
        dataForBeacon_3.metric2 = 2
        dataForBeacon_3.metric3 = 1

        var beaconDict = Dictionary<String, DataForBeacon>()
        beaconDict["1"] = dataForBeacon_1
        beaconDict["2"] = dataForBeacon_2
        beaconDict["3"] = dataForBeacon_3
        return beaconDict

    }

}

#endif

