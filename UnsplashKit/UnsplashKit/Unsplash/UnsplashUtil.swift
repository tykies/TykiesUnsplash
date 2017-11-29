//
//  UnsplashUtil.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit

public class Unsplash {
    
    public static var client : UnsplashClient?
    
    public static func setUpWithAppId(_ appId : String, secret : String, scopes: [String]=UnsplashAuthManager.publicScope) {
        precondition(appId != "APP_ID" && secret != "SECRET", "app id and secret are not valid")
        precondition(UnsplashClient.sharedClient == nil, "only call `UnsplashClient.init` one time")
        
        UnsplashAuthManager.sharedAuthManager = UnsplashAuthManager(appId: appId, secret: secret, scopes: scopes)
        UnsplashClient.sharedClient = UnsplashClient(appId: appId)
        Unsplash.client = UnsplashClient.sharedClient
        
        if let token = UnsplashAuthManager.sharedAuthManager.getAccessToken() {
            UnsplashClient.sharedClient.accessToken = token
        }
    }
    
    public static func unlinkClient() {
        precondition(UnsplashClient.sharedClient != nil, "call `UnsplashClient.init` before calling this method")
        
        Unsplash.client = nil
        UnsplashClient.sharedClient = nil
        UnsplashAuthManager.sharedAuthManager.clearAccessToken()
        UnsplashAuthManager.sharedAuthManager = nil
    }
    
    public static func authorizeFromController(controller: UIViewController, completion:@escaping (Bool, NSError?) -> Void) {
        precondition(UnsplashAuthManager.sharedAuthManager != nil, "call `UnsplashAuthManager.init` before calling this method")
        precondition(!UnsplashClient.sharedClient.authorized, "client is already authorized")
        
        UnsplashAuthManager.sharedAuthManager.authorizeFromController(controller, completion: { token, error in
            if let accessToken = token {
                UnsplashClient.sharedClient.accessToken = accessToken
                completion(true, nil)
            } else  {
                completion(false, error!)
            }
        })
    }
}
