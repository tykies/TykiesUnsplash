//
//  CurrentUserRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation

public class CurrentUserRoutes {
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func profile() -> UnsplashRequest<User.Serializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        return UnsplashRequest(client: self.client, route: "/me", auth: true, params: nil, responseSerializer: User.Serializer())
    }
    
    public func updateProfile(username: String?=nil, firstName: String?=nil, lastName: String?=nil, email: String?=nil, portfolioURL: NSURL?=nil, location: String?=nil,
                              bio: String?=nil, instagramUsername: String?=nil) -> UnsplashRequest<User.Serializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        var params = [String : AnyObject]()
        if let u = username {
            params["username"] = u as AnyObject
        }
        if let f = firstName {
            params["first_name"] = f as AnyObject
        }
        if let l = lastName {
            params["last_name"] = l as AnyObject
        }
        if let e = email {
            params["email"] = e as AnyObject
        }
        if let p = portfolioURL {
            params["url"] = p.absoluteString as AnyObject
        }
        if let l = location {
            params["location"] = l as AnyObject
        }
        if let b = bio {
            params["bio"] = b as AnyObject
        }
        if let i = instagramUsername {
            params["instagram_usernam"] = i as AnyObject
        }
        return UnsplashRequest(client: self.client, method:.put, route: "/me", auth: true, params: params, responseSerializer: User.Serializer())
    }
}
