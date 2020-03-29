//
//  File.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit

class LFOverlay{
    
    fileprivate var overlayView: UIView?
    fileprivate var activityIndicator: UIActivityIndicatorView?
    var titleLabel: UILabel?
    
    // MARK: Start Overlay
    func showOverlay(forView v: UIView, withTitle title: String?){
        v.addSubview(getOverlay(forFrame: v.frame, withTitle: title))
    }
    
    func showOverlayOverAppWindow(withTitle title: String?) {
        let currentScreenBounds = UIScreen.main.bounds
        UIApplication.shared.keyWindow?.addSubview(getOverlay(forFrame: currentScreenBounds, withTitle: title))
    }
    
    fileprivate func getOverlay(forFrame frame:CGRect, withTitle title: String?) -> UIView {
        
        // overlay view
        overlayView = UIView(frame: frame)
        overlayView!.backgroundColor = Style.OverLayColor.withAlphaComponent(0.55)
        
        // activity indicator
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 100, height: 100))
        activityIndicator!.center = overlayView!.center
        activityIndicator!.hidesWhenStopped = true
        activityIndicator!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        overlayView!.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
        
        // optional title
        if title != nil {
            let yCord = (overlayView?.center.y)! - 40
            titleLabel = UILabel(frame: CGRect(x: 0, y: yCord, width: AppSize.screenWidth, height: 0))
            titleLabel?.textColor = .white
            titleLabel?.text = title!
            titleLabel?.textAlignment = .center
            titleLabel?.font = titleLabel?.font.withSize(25.0)
            titleLabel?.bounds.size = (titleLabel?.intrinsicContentSize)!
            overlayView!.addSubview(titleLabel!)
        }
        
        return overlayView!
    }
    
    // MARK: End Overlay
    func endOverlay() {
        activityIndicator?.stopAnimating()
        overlayView?.removeFromSuperview()
    }
    
}

