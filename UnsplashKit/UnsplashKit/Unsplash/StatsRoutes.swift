//
//  StatsRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class StatsRoutes {
    
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func totalDownloads() -> UnsplashRequest<Stats.Serializer> {
        return UnsplashRequest(client: self.client, route: "/stats/total", auth: false, params: nil, responseSerializer: Stats.Serializer())
    }
}
