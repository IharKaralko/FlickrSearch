//
//  AppDelegate.swift
//  FlickrApp
//
//  Created by Ihar Karalko on 9/11/17.
//  Copyright © 2017 Ihar Karalko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = .white
       
        if let barFont = UIFont(name: "AppleSDGothicNeo-Light", size: 24){
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: barFont]
        }
        return true
    }
}

