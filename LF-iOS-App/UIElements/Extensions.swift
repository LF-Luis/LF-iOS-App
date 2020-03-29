//
//  Extensions.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import CoreLocation

extension CLLocationManager {
    
    func startRangingBeacons(inRegions regions: Set<CLBeaconRegion>) {
        for reg in regions {
            startRangingBeacons(in: reg)
        }
    }
    
    func startMonitoring(forRegions regions: Set<CLBeaconRegion>) {
        for reg in regions {
            startMonitoring(for: reg)
        }
    }
    
    func stopRangingBeacons(inRegions regions: Set<CLBeaconRegion>) {
        for reg in regions {
            stopRangingBeacons(in: reg)
        }
    }
    
    func stopMonitoring(forRegions regions: Set<CLBeaconRegion>) {
        for reg in regions {
            stopMonitoring(for: reg)
        }
    }
    
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

//// MARK: UIView Extension

extension UIView {
    
    /**
     For one or multiple views, set translatesAutoresizingMaskIntoConstraints to false.
     This is usually done before using addConstraintsWithFormat()
     
     -Author:
     Luis Fernandez
     
     -Returns:
     Your view with translatesAutoresizingMaskIntoConstraints set to false.
     
     -Parameters:
     One or multiple views.
     */
    
    
//    var LFExtension: LFViewExtn {
//        get {
//            return associatedObject(base: self, key: &LFViewExtensionKey)
//            { return LFViewExtn() } // Set the initial value of the var
//        }
//        set { associateObject(base: self, key: &LFViewExtensionKey, value: newValue) }
//    }

    func addMultipleSubviews(_ views: UIView...) {
        for viewI in views {
            addSubview(viewI)
        }
    }

    func setTranslatesAutoresizingMaskIntoConstraintsFalse(_ views: UIView...) {
        for viewI in views {
            viewI.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addConstraintsWithVisualFormat(_ format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }

}



