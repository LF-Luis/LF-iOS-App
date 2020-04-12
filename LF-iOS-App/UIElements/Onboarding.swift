//
//  AppOnboarding.swift
//  LF-iOS-App
//
//  Copyright © 2018 - 2019 Luis Fernandez. All rights reserved.
//

import UIKit
import Onboard


class AppOnboarding {
//class AppOnboarding: OnboardingViewController {

    class func onboardingViewController(completionHandler: @escaping () -> Void) -> OnboardingViewController {

        /*
         This class function returns an OnboardingViewController that can be used at any time. However, the purpose of use is only when the User is not logged in and when the User wants to get more information on how the app works.
         */

        // General Set Up

        let backgroundImg = UIImage(named: "whiteBackground")
        let iconWidth = AppSize.screenWidth
        let iconHeight = AppSize.screenHeight * 0.725 //0.65
        let a = AppSize.screenHeight * (1.25/40)
        let b = AppSize.screenHeight * (2/40)
        let c = AppSize.screenHeight * (3/40)
        let topPadding = a + (1.6*b) //(1.8*b)
        let underTitlePadding = iconHeight + ( 0.7 * c )
        let underIconPadding = -(iconHeight) - (0.6 * b) - a
        let titleTextSize = AppSize.screenHeight * (24/568)
        let bodyTextSize = AppSize.screenHeight * (20/568)
        let titleLabelFont = UIFont(name: "AppleSDGothicNeo-Bold", size: titleTextSize)
        let bodyLabelFont = UIFont(name: "AppleSDGothicNeo-Regular", size: bodyTextSize)

        // First Page

        let firstPage = OnboardingContentViewController(title: "Welcome to\nLF-iOS-App!", body: "This is an example of an oboarding flow.", image: nil, buttonText: "Next Page", action: nil)
        firstPage.movesToNextViewController = true
        firstPage.iconImageView.clipsToBounds = true
        firstPage.iconImageView.contentMode = .scaleAspectFit
        firstPage.iconWidth = AppSize.screenWidth * 0.85
        firstPage.iconHeight = iconHeight
        firstPage.titleLabel.font = titleLabelFont
        firstPage.bodyLabel.font = bodyLabelFont
        firstPage.titleLabel.textColor = .black
        firstPage.bodyLabel.textColor = .black
        firstPage.topPadding = topPadding + a
//                firstPage.bottomPadding = bottomPadding
        firstPage.underTitlePadding = 0.10 * (underTitlePadding - (1.8 * a))
        firstPage.underIconPadding = 0.6 * (underIconPadding - (a))
        firstPage.actionButton.backgroundColor = AppColors.mainBlue
        firstPage.actionButton.setTitleColor(.black, for: UIControlState.normal)
        firstPage.actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)

        // Second Page (Get In Line)

        let getInLine = OnboardingContentViewController(title: "First Things First",
                                                        body: "Welcome Users with a picture of your app in use!",
                                                        image: UIImage(named: "austin"),
                                                        buttonText: "Next Page", action: nil)
        getInLine.movesToNextViewController = true
        getInLine.iconImageView.clipsToBounds = true
        getInLine.iconImageView.contentMode = .scaleAspectFit
        getInLine.iconWidth = iconWidth
        getInLine.iconHeight = iconHeight
        getInLine.titleLabel.font = titleLabelFont
        getInLine.bodyLabel.font = bodyLabelFont
        getInLine.titleLabel.textColor = .black
        getInLine.bodyLabel.textColor = .black
        getInLine.topPadding = topPadding - (AppSize.screenHeight * 0.125)
        getInLine.underTitlePadding = underTitlePadding - (AppSize.screenHeight * 0.3)
        getInLine.underIconPadding = underIconPadding  + (AppSize.screenHeight * 0.155)
        getInLine.actionButton.backgroundColor = AppColors.mainBlue
        getInLine.actionButton.setTitleColor(.black, for: UIControlState.normal)
        getInLine.actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)

        // Next in line page

        let yourTurnPage = OnboardingContentViewController(title: "Secondly",
                                                         body: "What are the benefits of your app?",
                                                         image: UIImage(named: "bubbles"),
                                                         buttonText: "Next Page", action: nil)
        yourTurnPage.movesToNextViewController = true
        yourTurnPage.iconImageView.clipsToBounds = true
        yourTurnPage.iconImageView.contentMode = .scaleAspectFit
        yourTurnPage.iconWidth = iconWidth
        yourTurnPage.iconHeight = iconHeight
        yourTurnPage.titleLabel.font = titleLabelFont
        yourTurnPage.bodyLabel.font = bodyLabelFont
        yourTurnPage.titleLabel.textColor = .black
        yourTurnPage.bodyLabel.textColor = .black
        yourTurnPage.topPadding = topPadding - (AppSize.screenHeight * 0.125)
        yourTurnPage.underTitlePadding = underTitlePadding - (AppSize.screenHeight * 0.3)
        yourTurnPage.underIconPadding = underIconPadding  + (AppSize.screenHeight * 0.155)
        yourTurnPage.actionButton.backgroundColor = AppColors.mainBlue
        yourTurnPage.actionButton.setTitleColor(.black, for: UIControlState.normal)
        yourTurnPage.actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)

        // Last Page

        let lastPage = OnboardingContentViewController(title: "Lastly!",
                                                       body: "Following is a sample verification-step using phone number.",
                                                         image: UIImage(named: "coffee"),
                                                         buttonText: "Get Started!"){
                                                            completionHandler()
                                                        }
        lastPage.iconImageView.clipsToBounds = true
        lastPage.iconImageView.contentMode = .scaleAspectFit
        lastPage.iconWidth = iconWidth
        lastPage.iconHeight = iconHeight
        lastPage.titleLabel.font = titleLabelFont
        lastPage.bodyLabel.font = bodyLabelFont
        lastPage.titleLabel.textColor = .black
        lastPage.bodyLabel.textColor = .black
        lastPage.topPadding = topPadding - (AppSize.screenHeight * 0.125)
        lastPage.underTitlePadding = underTitlePadding - (AppSize.screenHeight * 0.3)
        lastPage.underIconPadding = underIconPadding  + (AppSize.screenHeight * 0.155)
        lastPage.actionButton.backgroundColor = AppColors.mainBlue
        lastPage.actionButton.setTitleColor(.black, for: UIControlState.normal)
        lastPage.actionButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22.0)

        // Controller Settings

        let onboradingVC = OnboardingViewController(backgroundImage: nil, contents: [firstPage, getInLine, yourTurnPage, lastPage])

        onboradingVC!.swipingEnabled = true
//        self.shouldMaskBackground = true
        onboradingVC!.backgroundImage = backgroundImg
//        onboradingVC!.view.backgroundColor = .white
        onboradingVC!.shouldBlurBackground = false
        onboradingVC!.shouldMaskBackground = false
        onboradingVC!.shouldFadeTransitions = true
        onboradingVC!.allowSkipping = false

        onboradingVC!.pageControl.currentPageIndicatorTintColor = AppColors.mainBlue
        onboradingVC!.pageControl.pageIndicatorTintColor = AppColors.backgroundGray

        onboradingVC!.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            // From iOS 13 and onwards, the default modal presentation has changed.
            // This variable is set so that the current presentable view is no able to be
            // swiped away
            onboradingVC!.isModalInPresentation = true
        }

        return onboradingVC!

        // Placing Pages
//        self.viewControllers = [firstPage, getInLine, yourTurnPage, lastPage]

    }

}


