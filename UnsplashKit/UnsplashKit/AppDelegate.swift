//
//  AppDelegate.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/9.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    Unsplash.setUpWithAccess("00500f2aa25c9d5aa716bc39d53670318fa8727ce0b4bb283f48588991a44c8b",
                                secret: "59affc47215f8fa4ffbefd8d2a3f00d97b15d2f23151aa7ea37f85dabe2e1759",
                                scopes: UnsplashOAuthManager.allScopes)
        
        return true
    }

}

