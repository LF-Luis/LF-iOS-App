//
//  HeaderView.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit

/*
 Header view cell for HomeCollectionVC
 */

class HeaderViewCell: UICollectionViewCell {

    private var titleTextView: UITextView = {
        let tF = UITextView()
        tF.text = ""
        tF.backgroundColor = .white
        tF.sizeToFit()
        tF.isEditable = false
        tF.isSelectable = false
        tF.isScrollEnabled = false
        tF.showsVerticalScrollIndicator = false
        tF.showsHorizontalScrollIndicator = false
        tF.textColor = FontColor.lightGray
        tF.textAlignment = .center
        tF.textContainerInset = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        tF.textContainer.lineFragmentPadding = 0
        tF.font = AppFonts.cellDescription(size: 14)
        return tF
    }()

    private var iconImg: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "information"))
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private var infoMessage: String = ""

    // MARK: - View Initiation
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()

        // Set up tap gesture of cell
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellWasSelected)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    private func setUp() {

        var frameHeight = frame.height
        if frameHeight == 0 {
            // This value should be set from the set up of the header cell.
            frameHeight = AppSize.headerCellHeight
        }

        self.addMultipleSubviews(titleTextView, iconImg)
        self.setTranslatesAutoresizingMaskIntoConstraintsFalse(titleTextView, iconImg)
        self.layer.masksToBounds = true
        let padding: Int = 6
        self.addConstraintsWithVisualFormat("V:|-\(padding)-[v0]-0-|", views: titleTextView)
        self.addConstraintsWithVisualFormat("H:|-\(padding)-[v0]-\(padding)-|", views: titleTextView)
        let addPad: Int = 5
        let width = Int(frameHeight) - padding - addPad - addPad
        self.addConstraintsWithVisualFormat("V:|-\(padding + addPad)-[v0]-\(addPad)-|", views: iconImg)
        self.addConstraintsWithVisualFormat("H:[v0(\(width))]-\(padding + addPad + addPad + 6)-|", views: iconImg)

    }

    func setPopulatedDataState() {
        self.alpha = 1
        self.isHidden = false
        self.isUserInteractionEnabled = true
        self.titleTextView.text = "Tap For More Info"
        self.titleTextView.backgroundColor = .white
        self.infoMessage =  "Place more info on the app here." +
                            "\n\nMake the app easier to understand"
    }

    func setEmptyDataState() {
        // There's a bug in iOS 13 that removes a header view when a collection view is empty.
        // For this reason, instead of showing a header view when empty, a button will be displayed
        // in the middle of the screen.
        self.alpha = 0
        self.isHidden = true
        self.isUserInteractionEnabled = false

//        self.titleTextView.text = "More Info"
//        self.titleTextView.backgroundColor = AppColors.backgroundGray
//        self.infoMessage =  "Place more info on the app here." +
//                            "\n\nMake the app easier to understand"

    }

    @objc
    private func cellWasSelected() {
        Alerts.presentSimple(title: "How The App Works", message: self.infoMessage, dissmissString: "Ok")
    }
    
}

