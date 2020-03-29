//
//  Style.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit

struct AppSize {
    static let screenWidth: CGFloat = UIScreen.main.bounds.size.width
    static let screenHeight: CGFloat = UIScreen.main.bounds.size.height
    static let screenFrame: CGRect = UIScreen.main.bounds
    static let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
    static let buttonHeight: CGFloat = 35.0
    static let viewCornerRadius: CGFloat = 9.0
    static let viewCornerRadiusSmall: CGFloat = 6.0
    static let headerCellHeight: CGFloat = 35.0
    static let homeViewCellHeight: CGFloat = 240.0
}

struct Style {
    static let OverLayColor = UIColor.black
    static let NavigationBarColor = UIColor.rgb(red: 81, green: 107, blue: 237, alpha: 0.5)
}

struct AppColors {
    static let mainBlue = UIColor.rgb(red: 81, green: 107, blue: 237, alpha: 1)
    static let cancelRed: UIColor = UIColor.rgb(red: 151, green: 43, blue: 17)
    static let promotionRed: UIColor = UIColor.rgb(red: 175, green: 42, blue: 95)
    static let mainColor: UIColor = UIColor.rgb(red: 81, green: 107, blue: 237, alpha: 1)
//    static let mainColor: UIColor = UIColor.rgb(red: 64, green: 111, blue: 197)
    static let grayFont: UIColor = UIColor.rgb(red: 187, green: 189, blue: 191)
    static let successGreen: UIColor = UIColor.rgb(red: 53, green: 199, blue: 89).withAlphaComponent(0.55)
    static let backgroundGray: UIColor = UIColor.rgb(red: 204, green: 207, blue: 212)
}

struct FontColor {
    static let lightGray: UIColor = UIColor.rgb(red: 103, green: 106, blue: 111)
    static let darkGray: UIColor = UIColor.rgb(red: 98, green: 103, blue: 107)
    static let darkAppFont: UIColor = UIColor.rgb(red: 186, green: 159, blue: 0)
}

struct AppFonts {

    static func navTitle(size: CGFloat = 20.0) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func boldTitle(size: CGFloat = 22.0) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: size) ?? UIFont.systemFont(ofSize: 25)
    }

    static func cellTitle(size: CGFloat = 22.0) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func cellDescription(size: CGFloat = 18.0) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func navBar(size: CGFloat = 22.0) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func softTitle(size: CGFloat = 16.0) -> UIFont {
        return UIFont(name: "SFProDisplay-Light", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static func button(size: CGFloat = 18.0) -> UIFont {
        return UIFont(name: "SFProDisplay-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    static let form = UIFont(name: "SFProDisplay-Regular", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 20.0)
    static let formFooter = UIFont(name: "SFProDisplay-Regular", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 15.0)

}

class Alerts {

    /**
     Determine if passed ViewController is usable, if not, try to get RootViewController.
     */
    private class func determineViewController(viewContrller vC: UIViewController?) -> UIViewController? {
        var returnVC: UIViewController!

        if vC != nil {
            returnVC = vC!
        }
        else {
            guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
                print("Failed to get keyWindow's rootViewController")
                return nil
            }
            returnVC = rootViewController
        }
        return returnVC
    }

    /**
     Simple alert with title, description, and dismiss action. If no View Controller is given, it
     will grab Root View Controller and present alert from there
     */
    class func presentSimple(title: String, message: String, dissmissString: String, withController vC: UIViewController? = nil) {
        guard let viewController = Alerts.determineViewController(viewContrller: vC) else {
            print("Failed to get usable View Controller, will not present Alert")
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dissmissString, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }

    /**
     Presents alert with "Yes" and "Cancel" action. "Cancel" dismisses the alert, "Yes" runs the
     completion handler.
     If no View Controller is given, it will grab Root View Controller and present alert from there.
     */
    class func present(
        title: String,
        message: String,
        completionString: String? = "Yes",
        cancelString: String? = "Cancel",
        withController vC: UIViewController? = nil,
        completionHandler: @escaping (() -> Void))
    {
        guard let viewController = Alerts.determineViewController(viewContrller: vC) else {
            print("Failed to get usable View Controller, will not present Alert")
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: completionString!, style: .default) { (uIAlertAction: UIAlertAction) in
            completionHandler()
        }

        let cancelAction = UIAlertAction(title: cancelString!, style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }

}

struct AppDescriptiveText {
    static let appDescription: String =  "This piece of text can be a short or long " +
        "description of the app." +
        "\nYou can state what the app is for." +
        "\n\n you can also state what is comming down the pipeline." +
        "\n\nHave fun with it!"
}
