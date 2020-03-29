//
//  ExpandCellForActionAHandler.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

// FIXME: Convert (with ExpandCellForActionAView) to a UIViewController to have more control on presentation

class ExpandCellForActionAHandler {

    private var expandCellForActionAView = ExpandCellForActionAView()
    private var imageView = UIImageView()
    private var dataForBeacon: DataForBeacon?
    private var viewCell: HomeCollectionViewCell!

    func expand(withCell cell: HomeCollectionViewCell) {

        self.viewCell = cell
        self.dataForBeacon = cell.dataForBeacon

        let imgView = cell.iconImg

        let swipeDownGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))

        expandCellForActionAView = ExpandCellForActionAView()
        expandCellForActionAView.addGestureRecognizer(swipeDownGesture)

        setUpToInitialState(imageView: imgView, dataForBeacon: cell.dataForBeacon)

    }

    private func setUpToInitialState(imageView: UIImageView, dataForBeacon: DataForBeacon) {

        self.imageView = imageView
        guard let keyWindow = UIApplication.shared.keyWindow else {
            Alerts.presentSimple(title: "Project",
                          message: "Cannot perform Action A at this moment, try again please.",
                          dissmissString: "Ok")
            return
        }

        expandCellForActionAView.setUpActionAButton(target: self, action: #selector(performActionA))
        expandCellForActionAView.setCancelAction(target: self, action: #selector(dismissView))

        expandCellForActionAView.initialState(imgView: imageView,
                                              titleText: dataForBeacon.mainName ?? "",
                                              withAppFrame: keyWindow.frame)

        self.expandCellForActionAView.setAlphasToZero()

        // Adding view to top of app window.
        keyWindow.addSubview(expandCellForActionAView)

        // Animation
        // 0.8 duration
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
            self.expandCellForActionAView.finalState(withAppFrame: keyWindow.frame)
        }, completion: nil)

    }

    /*
     Only allow the gesture of sliding down.
     When this gesture meets certain thresholds, the expandCellForActionAView will disappear
     */
    @objc private func panGestureRecognizerAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        var newOrigin = gestureRecognizer.translation(in: expandCellForActionAView)
        if newOrigin.y < 0 { return }
        newOrigin.x = 0
        self.expandCellForActionAView.frame.origin = newOrigin

        if gestureRecognizer.state == .ended {
            let vel = gestureRecognizer.velocity(in: expandCellForActionAView)

            if vel.y >= 1500 || newOrigin.y > 200 {
                self.dismissView()
            }
            else {
                UIView.animate(withDuration: 0.3) {
                    self.expandCellForActionAView.frame.origin = CGPoint.zero
                }
            }

        }

    }

    @objc private func performActionA() {

        let overlay = LFOverlay()
        overlay.showOverlay(forView: self.expandCellForActionAView, withTitle: nil)

        guard
            let dataForBeacon = self.dataForBeacon,
            let pM = ParametrizeForAPI.actionA(withDataForBcn: dataForBeacon)
        else {
            self.expandCellForActionAView.actionAError()
            overlay.endOverlay()
            return
        }

        AzureAPI.performActionA(parameters: pM) { (didSucceed: Bool) in
            if didSucceed {
                self.expandCellForActionAView.actionASucceeded()
                self.viewCell.setToActionAState()
                if self.dataForBeacon != nil {
                    self.dataForBeacon!.didPerformActionA = true
                }
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: AppSettingKeys.shouldUpdateSecondMainViewWithAPI)
            }
            else {
                self.expandCellForActionAView.actionAError()
            }
            overlay.endOverlay()
        }

    }

    @objc private func dismissView() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.expandCellForActionAView.dismiss()
        }) { (didSucceed: Bool) in
            self.expandCellForActionAView.removeFromSuperview()
        }
    }

}

