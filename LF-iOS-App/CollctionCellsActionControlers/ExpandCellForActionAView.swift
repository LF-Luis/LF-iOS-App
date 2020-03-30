//
//  ExpandCellForActionAView.swift
//  Alamofire
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit

class ExpandCellForActionAView: UIView {
    /*
     Starting out, this view will only show the image (iconImg). Then, it will expand to show a full
     view covering the entire app window.
     This view will ask the User if they want to perform Action A or not.
     */

    // MARK: - Variables

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.font = AppFonts.cellTitle()
        lbl.backgroundColor = .clear
        return lbl
    }()

    private var stateLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.font = AppFonts.cellDescription()
        lbl.backgroundColor = .clear
        return lbl
    }()

    private var iconImg: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    // Button to perform Action A
    private var actionAButton: LFMainButton = {
        let btn = LFMainButton()
        btn.makeRounded()
        return btn
    }()

    // Button to cancel Action A
    private var cancelButton: LFMainButton = {
        let btn = LFMainButton()
        btn.makeRounded()
        return btn
    }()

    // Width and length of check mark view
    private let checkmarkViewMainDimension: Int = 30

    lazy private var successCheckMark: UIImageView = {
        // When the image is first added to the view, it will be transparent.
        // When the User has succesfully performed Action A, the alpha will be set to 1.
        let img = UIImageView(image: UIImage(named: "checkmark"))
        img.backgroundColor = .clear
        img.layer.cornerRadius = CGFloat(self.checkmarkViewMainDimension / 2)
        img.clipsToBounds = true
        img.image = img.image?.withRenderingMode(.alwaysTemplate)
        img.tintColor = AppColors.successGreen
        return img
    }()

    private var backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = v.frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.tintColor = .white
        v.addSubview(blurEffectView)
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    // MARK: - Setup

    func setCancelAction(target: Any, action: Selector) {
        cancelButton.setUp(title: "Cancel", target: target, action: action)
//        cancelButton.backgroundColor = cancelButton.backgroundColor?.withAlphaComponent(0.8)
        cancelButton.setTitleColor(AppColors.cancelRed, for: .normal)
    }

    func setUpActionAButton(target: Any, action: Selector) {
        actionAButton.setUp(title: "Action A", target: target, action: action)
    }

    // MARK: - View's States

    /*
     The inital state of this view is only the image. The image must be set from the image that was
     selected, with the exact same dimensions and location on screen.
     */
    func initialState(imgView: UIImageView, titleText: String, withAppFrame frame: CGRect) {

        guard
            let initialImgFrame = imgView.superview?.convert(imgView.frame, to: nil)
            else {
                print("Unable to set initial state of ExpandCellForActionAView.")
                return
        }

        self.backgroundColor = .clear
        self.frame = frame
        self.iconImg.image = imgView.image
        self.iconImg.frame = initialImgFrame
        self.titleLabel.text = titleText
        self.successCheckMark.alpha = 0

        // Increasing the height so that when this view bounces with animation, the white under-
        // view is not shown.
        // The "y" origin is initiated at 80 so that a bounce animation is created when the final
        // "y" origin is 50
        self.backgroundView.frame = CGRect(x: 0, y: frame.height / 4, width: frame.width, height: frame.height + 200)

        self.addSubview(backgroundView)
        self.addSubview(iconImg)

    }

    func finalState(withAppFrame frame: CGRect) {

        // d1: calculated dimension for side padding of successCheckMark so that is is centered
        let d1 = (Int(AppSize.screenWidth) - checkmarkViewMainDimension) / 2

        self.backgroundView.frame.origin.y = 0
        self.iconImg.frame.origin.y = frame.height * 0.25

        self.addMultipleSubviews(titleLabel, actionAButton, cancelButton, stateLabel, successCheckMark)
        self.setAlphasToZero()
        self.setTranslatesAutoresizingMaskIntoConstraintsFalse(titleLabel, actionAButton, cancelButton, stateLabel, successCheckMark)
        self.layer.masksToBounds = true

        addConstraintsWithVisualFormat("H:|-9-[v0]-9-|", views: stateLabel)
        addConstraintsWithVisualFormat("H:|-\(d1)-[v0(\(checkmarkViewMainDimension))]", views: successCheckMark)
        addConstraintsWithVisualFormat("H:|-15-[v0]-15-|", views: titleLabel)
        addConstraintsWithVisualFormat("H:|-35-[v0]-35-|", views: actionAButton)
        addConstraintsWithVisualFormat("H:|-35-[v0]-35-|", views: cancelButton)
        addConstraintsWithVisualFormat("V:[v0(80)]-30-[v1]-80-[v2(30)]-20-[v3(30)]", views: titleLabel, iconImg, actionAButton, cancelButton)
        addConstraintsWithVisualFormat("V:[v0(30)]-40-[v1]", views: stateLabel, cancelButton)
        addConstraintsWithVisualFormat("V:[v0]-23-[v1(\(checkmarkViewMainDimension))]", views: iconImg, successCheckMark)

        backgroundView.alpha = 1
        self.setAlphasToOne()
    }

    // MARK: - View's States Helpers

    func dismiss() {
        self.frame.origin.y = self.frame.height
    }

    func setAlphasToZero() {
        titleLabel.alpha = 0
        actionAButton.alpha = 0
        cancelButton.alpha = 0
    }

    func setAlphasToOne() {
        titleLabel.alpha = 1
        actionAButton.alpha = 1
        cancelButton.alpha = 1
    }

    // MARK: - Action A Responses

    func actionASucceeded() {

        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.actionAButton.alpha = 0
            self.successCheckMark.alpha = 1
            self.actionAButton.isEnabled = false
            self.stateLabel.text = "Action A Done!"
            self.cancelButton.setTitle("Done", for: .normal)
        }, completion: nil)

        //        self.__anyViewWithConstraints.transform = CGAffineTransform(translationX: 0, y: 40)

    }

    func actionAError() {
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.stateLabel.text = "Failed to perform Action A. Please try again."
        }, completion: nil)
    }

}



