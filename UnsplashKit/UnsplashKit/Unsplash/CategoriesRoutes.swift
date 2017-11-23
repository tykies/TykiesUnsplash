//
//  CategoriesRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class CategoriesRoutes {
    
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func all() -> UnsplashRequest<CategoriesResult.Serializer> {
        return UnsplashRequest(client: self.client, route: "/categories", auth: false, params: nil, responseSerializer: CategoriesResult.Serializer())
    }
    
    public func findCategory(categoryId: UInt32) -> UnsplashRequest<Category.Serializer> {
        let params = ["id" : NSNumber(value: categoryId)]
        return UnsplashRequest(client: self.client, route: "/categories/\(categoryId)", auth: false, params: params, responseSerializer: Category.Serializer())
    }
    
    public func photosForCategory(categoryId: UInt32, page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<PhotosResult.Serializer> {
        var params = ["id" : NSNumber(value: categoryId)]
        if let page = page {
            params["page"] = NSNumber(value: page)
        }
        if let perPage = perPage {
            params["per_page"] = NSNumber(value: perPage)
        }
        return UnsplashRequest(client: self.client, route: "/curated_batches/\(categoryId)/photos", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
}

