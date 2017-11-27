//
//  UsersRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class UsersRoutes {
    
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func findUser(username: String, width: UInt32?=nil, height: UInt32?=nil) -> UnsplashRequest<User.Serializer> {
        var params : [String : AnyObject] = ["username" : username as AnyObject]
        if let w = width {
            params["width"] = NSNumber(value: w)
        }
        if let h = height {
            params["height"] = NSNumber(value: h)
        }
        return UnsplashRequest(client: self.client, route: "/users/\(username)", auth: false, params: params, responseSerializer: User.Serializer())
    }
    
    public func photosForUser(username: String) -> UnsplashRequest<PhotosResult.Serializer> {
        let params = ["username" : username] as [String : AnyObject]
        return UnsplashRequest(client: self.client, route: "/users/\(username)/photos", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
    public func likesForUser(username: String, page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<PhotosResult.Serializer> {
        var params : [String : AnyObject] = ["username" : username as AnyObject]
        if let p = page {
            params["page"] = NSNumber(value: p)
        }
        if let pp = perPage {
            params["per_page"] = NSNumber(value: pp)
        }
        return UnsplashRequest(client: self.client, route: "/users/\(username)/likes", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
}
