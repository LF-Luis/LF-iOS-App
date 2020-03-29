//
//  DebugRealm.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import CoreLocation
import Realm
import RealmSwift

/*
 DO NOT use this class in main business logic of app, ists purpose is for debugging or for making
 drastic changes to the User's local Realm DB.
 RealmDebug.deleteAllDirectories()
 RealmDebug.deleteAllObjects()
 */

class RealmDebug {

    class func deleteAllDirectories() {

        print("Will try deleting all Realm dirs.")

        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!

        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("note"),
            realmURL.appendingPathExtension("management")
        ]

        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
                print("Deleted \(URL)")
            } catch {
                // handle error
                print("Failed at removing REALM, at: \(URL).")
            }
        }

        print("Done trying to delete Realm's dirs.")

    }

    class func deleteAllObjects() {

        print("Will try deleting all Realm objects")

        let realm = try! Realm()

        // Delete all objects from the realm
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Failed to delete all objects.")
        }

        print("Done trying to delete all Realm objects")

    }

}
