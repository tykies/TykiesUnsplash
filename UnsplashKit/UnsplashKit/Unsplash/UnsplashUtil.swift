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
    
    public static func setUpWithAccess(_ access : String, secret : String, scopes: [String]=UnsplashOAuthManager.publicScope) {
        precondition(access != "APP_ID" && secret != "SECRET", "app id and secret are not valid")
        precondition(UnsplashClient.sharedClient == nil, "only call `UnsplashClient.init` one time")
        
        UnsplashOAuthManager.sharedOAuthManager = UnsplashOAuthManager(access: access, secret: secret, scopes: scopes)
        UnsplashClient.sharedClient = UnsplashClient(access: access)
        Unsplash.client = UnsplashClient.sharedClient
        
        if let token = UnsplashOAuthManager.sharedOAuthManager.getAccessToken() {
            UnsplashClient.sharedClient.accessToken = token
        }
    }
    
    public static func unlinkClient() {
        precondition(UnsplashClient.sharedClient != nil, "call `UnsplashClient.init` before calling this method")
        
        Unsplash.client = nil
        UnsplashClient.sharedClient = nil
        UnsplashOAuthManager.sharedOAuthManager.clearAccessToken()
        UnsplashOAuthManager.sharedOAuthManager = nil
    }
    
    public static func authorizeFromController(controller: UIViewController, completion:@escaping (Bool, NSError?) -> Void) {
        precondition(UnsplashOAuthManager.sharedOAuthManager != nil, "call `UnsplashOAuthManager.init` before calling this method")
        precondition(!UnsplashClient.sharedClient.authorized, "client is already authorized")
        
        UnsplashOAuthManager.sharedOAuthManager.authorizeFromController(controller, completion: { token, error in
            if let accessToken = token {
                UnsplashClient.sharedClient.accessToken = accessToken
                completion(true, nil)
            } else  {
                completion(false, error!)
            }
        })
    }
}
