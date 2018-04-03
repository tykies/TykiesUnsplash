//
//  UnsplashClient.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class UnsplashClient {
    let host : String
    let manager : SessionManager
    let appId : String
    public var collections : CollectionsRoutes!
    public var categories : CategoriesRoutes!
    public var stats : StatsRoutes!
    public var photos : PhotosRoutes!
    public var users : UsersRoutes!
    public var currentUser : CurrentUserRoutes!
    public var accessToken : UnsplashAccessToken?
    
    public static var sharedClient : UnsplashClient!
    
    public init(appId: String, manager: SessionManager, host: String) {
        self.appId = appId
        self.host = host
        self.manager = manager
        self.collections = CollectionsRoutes(client: self)
        self.categories = CategoriesRoutes(client: self)
        self.stats = StatsRoutes(client: self)   
        self.photos = PhotosRoutes(client: self)
        self.users = UsersRoutes(client: self)
        self.currentUser = CurrentUserRoutes(client: self)
    }
    
    
    public convenience init(appId: String) {
        let manager = SessionManager()
        manager.startRequestsImmediately = false
        self.init(appId: appId, manager: manager, host: "https://api.unsplash.com")
    }
    
    public func additionalHeaders(authNeeded: Bool) -> [String : String] {
        var headers = [
            "Accept-Version" : "v1",
            "Content-Type" : "application/json",
            ]
        if (authNeeded) {
            headers["Authorization"] = "Bearer \(self.accessToken!.accessToken)"
        } else {
            headers["Authorization"] = "Client-ID \(self.appId)"
        }
        return headers
    }
    
    public var authorized : Bool {
        return self.accessToken != nil
    }
}
