//
//  AppDelegate.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import CoreLocation
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Realm migrations
        // see: https://realm.io/docs/swift/latest/#migrations
        let config = Realm.Configuration(
            // Must be done on every migration, increase schemaVersion by 1
            schemaVersion: 1,
            // migrationBlock will be called if the current schemaVersion is less than the one
            // just set
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )
        // Set Realm to use the new config as default
        Realm.Configuration.defaultConfiguration = config
        // Opening the file will automatically perform the migration
        let _ = try! Realm()

        // MARK:- Initial view setup
        // Set up initial navigation controller and view controller (not using Storyboard)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white

        // HomeCollectionVC:
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset.top = 11.0
        layout.sectionInset.bottom = 11.0
        layout.minimumLineSpacing = 22
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.invalidateLayout()
        let homeCollectionVC = HomeCollectionVC(collectionViewLayout: layout)
        let mainController = UINavigationController(rootViewController: homeCollectionVC)
        mainController.navigationBar.isTranslucent = true
        mainController.navigationBar.tintColor = .black
        mainController.navigationBar.barTintColor = Style.NavigationBarColor

        // Navigation bar title style
        let navigationFont = AppFonts.navTitle()
        let attributes = [NSAttributedStringKey.font: navigationFont]
        UINavigationBar.appearance().titleTextAttributes = attributes

        // DEPRECATED: Old UI with large navigation font
        // Setting navigtion font
//        let navigationFont = UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 20.0)
//        let largeNavigationFont = UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 34.0)
//        let attributes = [NSAttributedStringKey.font: navigationFont]
//        UINavigationBar.appearance().titleTextAttributes = attributes
//
//        if #available(iOS 11, *) {
//            UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.font: largeNavigationFont]
//        }

        self.window?.rootViewController = mainController
        self.window?.makeKeyAndVisible()

        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

