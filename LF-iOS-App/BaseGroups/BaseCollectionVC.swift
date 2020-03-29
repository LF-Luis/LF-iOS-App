//
//  LFCollectionVC.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class BaseCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    let refreshControl = UIRefreshControl()

//    var navigationTitle: String? {
//        didSet {
//            if let str = navigationTitle {
//                navigationLabel.text = str
//            }
//        }
//    }
//
//    let navigationLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = ""
//        lbl.font = UIFont(name: "SF-Pro-Text-Light.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 18.0)
//        lbl.textColor = UIColor.black
//        lbl.sizeToFit()
//        return lbl
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        // Set-up empty data set view delegate
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: AppFonts.navBar(size: 18)]
    }

    private func scrollTopOfCV() {
        // This method scrolls to the top of the collection view
        collectionView?.reloadData()
        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        collectionView?.isScrollEnabled = false
    }

    // MARK:- Pull to Refresh

    /**
     If using "pull to refresh", do not forget to call self.refreshControl.endRefreshing() to stop
     refreshing animation.
     */
    func setUpPullToRefresh() {
        // Set-up pull to refrech control
        self.collectionView?.refreshControl = refreshControl
        self.refreshControl.addTarget(self, action: #selector(pullToRefreshAction(_:)), for: .valueChanged)

        // UI edits

        let mainColor = UIColor.darkGray

        self.refreshControl.tintColor = mainColor

        let text: String = "Pull Down to Refresh"
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: mainColor
        ]
        self.refreshControl.attributedTitle = NSAttributedString(string: text, attributes: attributes)
    }

    // Empty function, if it's used then set its action in the view controller that inherited from this one
    @objc func pullToRefreshAction(_ sender: Any) {}

    // MARK:- UICollectionViewDelegate Methods

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool { return true }

    // MARK:- DZNEmptyDataSet Delegate and Data Source Methods

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {

        guard let cgImg = UIImage(named: "EmptyDataSet")?.cgImage else {
            return UIImage(named: "LaunchScreenPic")
        }
        
        return UIImage(cgImage: cgImg, scale: 10, orientation: UIImageOrientation.up)
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let text: String = "This is the title when there's no data."
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 30.0),
            NSAttributedStringKey.foregroundColor: AppColors.grayFont
        ]

        return NSAttributedString(string: text, attributes: attributes)

    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let text: String = "This is the description when there's no data."
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center

        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont(name: "SF-Pro-Display-Medium.otf", size: UIFont.systemFontSize) ?? UIFont.systemFont(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor: AppColors.grayFont,
            NSAttributedStringKey.paragraphStyle: paragraph
        ]

        return NSAttributedString(string: text, attributes: attributes)

    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -(AppSize.screenHeight / 10)
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return false
    }

}

protocol Title {
    var label: UILabel { get }
    func setNavigation(text: String)
}

extension Title {
    var label: UILabel {
        let label = UILabel()
        label.text = ""
//        label.font = UIFont(name: "SF-Pro-Text-Light.otf", size: UIFont.systemFontSize)
        label.textColor = UIColor.black
        label.sizeToFit()
        return label
    }
}

extension Title where Self: UIViewController {
    func setNavigation(text: String) {
        label.text = text
        self.navigationItem.titleView = label
    }
}

