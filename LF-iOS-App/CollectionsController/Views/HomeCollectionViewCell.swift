//
//  HomeCollectionViewCell.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

// protocal used for delegation from HomeCollectionViewCell
protocol HomeCollectionViewCellDelegate: AnyObject {
    /*
     For the open source version of iOS app, a few actions for the cell have been left:
     performActionA and performActionB are based on actions that this cell can perform. In the
     current cell setup, action A is performed when "button A" is pressed and action B is performed
     when anywhere in the cell is pressed.
     */
    func homeCollectionViewCell(performActionA fromCell: HomeCollectionViewCell)
    func homeCollectionViewCell(performActionB fromCell: HomeCollectionViewCell)
}

// main class
class HomeCollectionViewCell: UICollectionViewCell {

    // MARK: - Variables

    // Images are cached based on url (i.e. url-string is used as the key)
    // This is a static private object because it will be used multiple times as each cell is created
    static private let imgCache = NSCache<NSString, UIImage>()

    weak var delegate: HomeCollectionViewCellDelegate?

    var dataForBeacon = DataForBeacon()

    lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        lbl.font = AppFonts.cellTitle(size: 16.0)
        lbl.backgroundColor = .clear
        return lbl
    }()

    var metric1Label: UILabel = {
        let txtView = UILabel()
        txtView.numberOfLines = 1
        txtView.lineBreakMode = NSLineBreakMode.byWordWrapping
        txtView.font = AppFonts.cellDescription(size: 13.0)
        txtView.textColor = FontColor.darkAppFont
        txtView.backgroundColor = .clear
        return txtView
    }()

    var metric2Label: UILabel = {
        let txtView = UILabel()
        txtView.numberOfLines = 1
        txtView.lineBreakMode = NSLineBreakMode.byWordWrapping
        txtView.font = AppFonts.cellDescription(size: 13.0)
        txtView.textColor = FontColor.lightGray
        txtView.backgroundColor = .clear
        txtView.textAlignment = NSTextAlignment.center
        return txtView
    }()

    var metric3Label: UILabel = {
        let txtView = UILabel()
        txtView.numberOfLines = 1
        txtView.lineBreakMode = NSLineBreakMode.byWordWrapping
        txtView.font = AppFonts.cellDescription(size: 13.0)
        txtView.textColor = FontColor.lightGray
        txtView.backgroundColor = .clear
        txtView.textAlignment = NSTextAlignment.center
        return txtView
    }()

    lazy var iconImg: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    var shortExtraTxtLbl: UILabel = {
        let txtView = UILabel()
        txtView.alpha = 0
        txtView.numberOfLines = 1
        txtView.lineBreakMode = NSLineBreakMode.byWordWrapping
        txtView.font = AppFonts.boldTitle(size: 16.5)
        txtView.textColor = AppColors.promotionRed
        txtView.backgroundColor = .white
        txtView.textAlignment = NSTextAlignment.center
        txtView.layer.borderWidth = 1.3
        txtView.layer.borderColor = UIColor.rgb(red: 151, green: 152, blue: 156).cgColor
//        txtView.layer.cornerRadius = AppSize.viewCornerRadiusSmall
        return txtView
    }()

    private var actionAButton: LFMainButton = {
        let button = LFMainButton()
        button.setUp(title: "Action A")
        button.backgroundColor = .white
        button.layer.borderWidth = 1.3
        button.layer.borderColor = UIColor.rgb(red: 151, green: 152, blue: 156).cgColor
        button.titleLabel?.font = AppFonts.cellTitle(size: 13.5)
        button.setTitleColor(FontColor.darkGray, for: .normal)
        button.makeRounded(radius: AppSize.viewCornerRadiusSmall)
        return button
    }()

    private var lineView: UIView = {
        let l = UIView()
        l.backgroundColor = .clear
        return l
    }()

    // MARK: - View Initiation
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        // Init shortExtraTxtLbl label to be transparrent (in case the cell does not have a promotion)
        self.shortExtraTxtLbl.alpha = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Cell's actions

    /**
     Calls the delegator to perform action when the cell itself is selected.
     */
    @objc func handleInfoSelection() {
        if let delegate = delegate {
            delegate.homeCollectionViewCell(performActionB: self)
        }
    }

    /**
     Calls the delegator to performs Action A when iconImg is tapped.
     */
    @objc func handleActionA(tapGesture: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.homeCollectionViewCell(performActionA: self)
        }
    }

    /**
     Calls the delegator to cancel Action A
     */
    @objc func cancelActionA(tapGesture: UITapGestureRecognizer) {
        UserStateManager.cancelActionA(ofDataBeacon: self.dataForBeacon) { (didSucceed: Bool) in
            if didSucceed { self.setToCanceledActionAState() }
            return
        }
    }

    // MARK: - Setup
    
    func setUp(withBeaconData dataForBeacon: DataForBeacon, shouldHandleActionA: Bool = false) {

        self.dataForBeacon = dataForBeacon

        self.metric1Label.text = "\(dataForBeacon.metric1) " + "\(dataForBeacon.metric1 == 1 ? "Thing" : "Things")"
        self.metric2Label.text = "\(dataForBeacon.metric2) " + "\(dataForBeacon.metric2 == 1 ? "Metric" : "Metrics")"
        self.metric3Label.text = "\(dataForBeacon.metric3) " + "\(dataForBeacon.metric3 == 1 ? "Item" : "Items")"

        if dataForBeacon.mainName != nil {
            self.titleLabel.text = dataForBeacon.mainName!
        }
        else {
            self.titleLabel.text = "Unknown Beacon"
        }

        if let imageURL = dataForBeacon.imageUrl {
            self.asyncSetImg(withUrl: imageURL)
        }

        var imgHeight: Int = 155

        if shouldHandleActionA {
            imgHeight = 155
            // Check if Action A has already been perform for this cell
            if dataForBeacon.didPerformActionA {
                self.setToActionAState()
            }
            else {
                // Cells are reused, it may be the case that the previous owner of
                // this cell had perform Action A but this new instance is not. This is why
                // Action A state is set here.
                self.setToCanceledActionAState()
            }
        }
        else {
            self.lineView.backgroundColor = .darkGray
            imgHeight = 100
        }

        // Check if cell has a shortExtraStr, if so show shortExtraTxtLbl label
        if dataForBeacon.shortExtraStr != nil {
            self.shortExtraTxtLbl.text = dataForBeacon.shortExtraStr
            self.shortExtraTxtLbl.alpha = 1
        }

        // When anywhere in the cell is tapped, the User will get the info of the cell
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleInfoSelection)))
        // Set up views of the cell
        self.setUpViews(shouldHandleActionA: shouldHandleActionA, imgHeight: imgHeight)

    }

    private func setUpViews(shouldHandleActionA: Bool, imgHeight: Int) {

        self.contentView.addMultipleSubviews(titleLabel, metric1Label, iconImg, lineView, metric2Label, metric3Label, shortExtraTxtLbl)

        self.setTranslatesAutoresizingMaskIntoConstraintsFalse(titleLabel, metric1Label, iconImg, lineView, metric2Label, metric3Label, shortExtraTxtLbl)

        self.contentView.layer.masksToBounds = true;

        addConstraintsWithVisualFormat("H:|-0-[v0]-0-|", views: iconImg)
        addConstraintsWithVisualFormat("H:|-15-[v0]-15-|", views: titleLabel)
        addConstraintsWithVisualFormat("H:|-15-[v0]-15-|", views: metric1Label)
        addConstraintsWithVisualFormat("H:|-15-[v0]-15-|", views: lineView)
        addConstraintsWithVisualFormat("H:[v0(85)]-15-|", views: shortExtraTxtLbl)

        addConstraintsWithVisualFormat("V:|-6-[v0(20)]-3-[v1(16)]-6-[v2(\(imgHeight))]", views: titleLabel, metric1Label, iconImg)

        addConstraintsWithVisualFormat("V:[v0]-6-[v1]-|", views: iconImg, metric2Label)
        addConstraintsWithVisualFormat("V:[v0]-6-[v1]-|", views: iconImg, metric3Label)

        addConstraintsWithVisualFormat("V:[v0(1)]-0-|", views: lineView)

        addConstraintsWithVisualFormat("V:[v0(35)]-(-25)-[v1]", views: shortExtraTxtLbl, iconImg)

        let a1 = Int(AppSize.screenWidth - 300.0) / 5

        if shouldHandleActionA {
            contentView.addMultipleSubviews(actionAButton)
            setTranslatesAutoresizingMaskIntoConstraintsFalse(actionAButton)
            addConstraintsWithVisualFormat("V:[v0]-5-[v1]-6-|", views: iconImg, actionAButton)
            addConstraintsWithVisualFormat("H:|-\(a1)-[v0(100)]-\(a1)-[v1(100)]-\(a1)-[v2(100)]", views: metric2Label, metric3Label, actionAButton)
        }
        else {
            addConstraintsWithVisualFormat("H:|-55-[v0]", views: metric2Label)
            addConstraintsWithVisualFormat("H:[v0]-55-|", views: metric3Label)
        }

    }

    // MARK: - Image Set Functions
    func asyncSetImg(withUrl url: String) {

        let urlHashValue: NSString = String(url.hashValue) as NSString

        if let cachedVersion = HomeCollectionViewCell.imgCache.object(forKey: urlHashValue) {
            self.iconImg.image = cachedVersion
        }
        else {
            // FIXME: Lazily load images
            Alamofire.request(url).responseImage { (response: DataResponse<Image>) in
                if
                    response.error == nil,
                    response.data != nil,
                    let img = UIImage(data: response.data!)
                {
                    self.iconImg.image = img
                    HomeCollectionViewCell.imgCache.setObject(img, forKey: urlHashValue)
                }
                else {
                    print("HomeCollectionViewCell.asyncSetImg(...) Could not get image from url: \(url)")
                }
            }
        }

    }

    // MARK: - Cell State

    /*
     The User has performed Action A successfully, the UI of this cell will be updated to reflect that.
     The main part of the cell that is updated is the actionAButton, changing it's background color,
     and title to reflect success.
     */
    func setToActionAState() {
        self.dataForBeacon.didPerformActionA = true
        self.actionAButton.removeTarget(nil, action: nil, for: .touchUpInside)
        self.actionAButton.addTarget(self, action: #selector(cancelActionA), for: .touchUpInside)
        self.actionAButton.backgroundColor = AppColors.successGreen
        self.actionAButton.setTitleColor(.black, for: .normal)
        self.actionAButton.setTitle("Action A Done!", for: .normal)
    }

    func setToCanceledActionAState() {
        self.dataForBeacon.didPerformActionA = false
        self.actionAButton.removeTarget(nil, action: nil, for: .touchUpInside)
        // If this cell is meant to handle Action A, then an "Action A" button will be used.
        self.actionAButton.addTarget(self, action: #selector(handleActionA), for: .touchUpInside)
        self.actionAButton.backgroundColor = .white
        self.actionAButton.setTitleColor(UIColor.rgb(red: 77, green: 77, blue: 86), for: .normal)
        self.actionAButton.setTitle("Action A", for: .normal)
    }

    // MARK: - Set Loading Style
    func setLoadingCellStyle(imgHeight: Int = 140) {

        titleLabel.text = " "
        metric1Label.text = " "
        titleLabel.font = titleLabel.font?.withSize(22)
        metric1Label.font = metric1Label.font?.withSize(16)
        iconImg.image = UIImage(named: "placeHolderCellIconImg")
        setUpViews(shouldHandleActionA: false, imgHeight: imgHeight)

        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1.3
        pulseAnimation.fromValue = 0.5
        pulseAnimation.toValue = 1.15
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        iconImg.layer.add(pulseAnimation, forKey: "animateOpacity")

    }

    // MARK: - Static, Public Facing APIs

    class func clearCachedData() {
        HomeCollectionViewCell.imgCache.removeAllObjects()
    }

}

