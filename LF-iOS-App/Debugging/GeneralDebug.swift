//
//  GeneralDebug.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import Foundation
import UIKit

class GeneralDebug: NSObject {

    class func printAllFonts() {

        print("----------------------------------------")
        print("------Printing all available fonts------")
        print("----------------------------------------")
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) -----")
            print("Font names: \(names)")
        }

        print("----------------------------------------")
        print("----------------------------------------")

    }

}

