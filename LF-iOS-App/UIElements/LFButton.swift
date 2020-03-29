//
//  LFButton.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit

// FIXME: Clean up code, make API easier to access and edit the button's features.

protocol LFButtonRounded {
    var connerRadius: CGFloat { get }
    var fontName: String { get }
    var fontSize: CGFloat { get }
    var font: UIFont { get }
    //    var frame: CGRect { get }
    var backgroundColor: UIColor { get }
    var textColor: UIColor { get }
    var text: String { get }
    var target: Any { get }
    var action: Selector { get }
    var controlEvent: UIControl.Event { get }
    var controlState: UIControl.State { get }
    var button: UIButton { get }
}

extension LFButtonRounded {
    var connerRadius: CGFloat { return 15.0 }
    var fontName: String { return "SFProDisplay-Thin" }
    var fontSize: CGFloat { return 18.0 }
    var backgroundColor: UIColor { return UIColor.rgb(red: 253, green: 148, blue: 124) }
    var textColor: UIColor { return UIColor.white }
    var font: UIFont {
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    var controlEvent: UIControl.Event { return UIControl.Event.touchUpInside }
    var controlState: UIControl.State { return UIControl.State.normal }
    var button: UIButton {
        let button = UIButton(frame: CGRect.zero)
        button.layer.cornerRadius = connerRadius
        button.titleLabel?.font = font
        button.backgroundColor = backgroundColor
        button.setTitleColor(textColor, for: controlState)
        button.setTitle(text, for: controlState)
        button.addTarget(target, action: action, for: controlEvent)
        return button
    }
}

struct LFButtonLarge: LFButtonRounded {
    var text: String
    var target: Any
    var action: Selector
}

protocol ButtonStyle {
    func setUp(title: String, target: Any, action: Selector)
    func makeRounded(radius: CGFloat)
}

extension ButtonStyle where Self: UIButton {
    func setUp(title: String, target: Any, action: Selector) {
        self.setUp(title: title)
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    func setUp(title: String) {
        self.titleLabel?.font = AppFonts.button()
        self.backgroundColor = AppColors.mainBlue
        self.setTitleColor(UIColor.black, for: .normal)
        self.setTitle(title, for: .normal)
    }
    func makeRounded(radius: CGFloat = 15.0) {
        self.layer.cornerRadius = radius
    }
    func enable(withTile title: String = "") {
        self.setTitle(title, for: .normal)
        self.isEnabled = true
        self.backgroundColor = AppColors.mainColor
    }
    func disable(withTile title: String = "") {
        self.setTitle(title, for: .normal)
        self.isEnabled = false
        self.backgroundColor = UIColor.gray
    }
}

class LFMainButton: UIButton, ButtonStyle {
}

