//
//  PhotosRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import CoreGraphics

public class PhotosRoutes {
    
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func findPhotos(page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<PhotosResult.Serializer> {
        var params = [String : AnyObject]()
        if let page = page {
            params["page"] = NSNumber(value: page)
        }
        if let perPage = perPage {
            params["per_page"] = NSNumber(value: perPage)
        }
        return UnsplashRequest(client: self.client, route: "/photos", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
    public func findPhoto(photoId: String, width: UInt32?=nil, height: UInt32?=nil, rect: CGRect?=nil) -> UnsplashRequest<Photo.Serializer> {
        var params : [String : AnyObject] = ["id" : photoId as AnyObject]
        if let w = width {
            params["w"] = NSNumber(value: w)
        }
        if let h = height {
            params["h"] = NSNumber(value: h)
        }
        if let r = rect {
            params["rect"] = "\(Int(r.origin.x)),\(Int(r.origin.y)),\(Int(r.size.width)),\(Int(r.size.height))" as AnyObject
        }
        return UnsplashRequest(client: self.client, route: "/photos/\(photoId)", auth: false, params: params, responseSerializer: Photo.Serializer())
    }
    
    public func search(query: String, categoryIds: Array<UInt32>?=nil, page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<PhotosResult.Serializer> {
        var params : [String : AnyObject] = ["query" : query as AnyObject]
        if let ids = categoryIds where ids.count > 0 {
            let strIds = ids.map({"\($0)"}).joinWithSeparator(",")
            params["category"] = strIds as AnyObject
        }
        if let page = page {
            params["page"] = NSNumber(value: page)
        }
        if let perPage = perPage {
            params["per_page"] = NSNumber(value: perPage)
        }
        return UnsplashRequest(client: self.client, route: "/photos/search", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
    public func random(query: String?=nil, categoryIds: Array<UInt32>?=nil, featured: Bool?=nil, username: String?=nil, width: UInt32?=nil, height: UInt32?=nil) -> UnsplashRequest<Photo.Serializer> {
        var params = [String : AnyObject]()
        if let q = query {
            params["query"] = q as AnyObject
        }
        if let ids = categoryIds where ids.count > 0 {
            let strIds = ids.map({"\($0)"}).joinWithSeparator(",")
            params["category"] = strIds as AnyObject
        }
        if featured != nil && featured! {
            params["featured"] = "true" as AnyObject
        }
        if let u = username {
            params["username"] = u as AnyObject
        }
        if let w = width {
            params["w"] = NSNumber(value: w)
        }
        if let h = height {
            params["h"] = NSNumber(value: h)
        }
        return UnsplashRequest(client: self.client, route: "/photos/random", auth: false, params: nil, responseSerializer: Photo.Serializer())
    }
    
    public func uploadPhoto(photo: UIImage, location: Location?=nil, exif: Exif?=nil) -> UnsplashRequest<Photo.Serializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        let data = UIImageJPEGRepresentation(photo, 0.7)
        var params = [String : AnyObject]()
        params["photo"] = data!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        if let l = location {
            var locationParams = [String : AnyObject]()
            if l.city != nil { locationParams["city"] = l.city as AnyObject }
            if l.country != nil { locationParams["country"] = l.country as AnyObject }
            if l.name != nil { locationParams["name"] = l.name as AnyObject }
            if (l.confidential != nil && l.confidential!) { locationParams["confidential"] = "true" as AnyObject }
            params["location"] = locationParams as AnyObject
        }
        if let e = exif {
            var exifParams = [String : AnyObject]()
            if e.make != nil { exifParams["make"] = e.make as AnyObject }
            if e.model != nil { exifParams["model"] = e.model as AnyObject }
            if e.exposureTime != nil { exifParams["exposure_time"] = NSNumber(value: e.exposureTime!) }
            if e.aperture != nil { exifParams["aperture_value"] = NSNumber(value: e.aperture!) }
            if e.focalLength != nil { exifParams["focal_length"] = NSNumber(value: e.focalLength!) }
            if e.iso != nil { exifParams["iso_speed_ratings"] = NSNumber(value: e.iso!) }
            params["exif"] = exifParams as AnyObject
        }
        
        return UnsplashRequest(client: self.client, method: .POST, route: "/photos", auth: true, params: params, responseSerializer: Photo.Serializer())
    }
    
    public func updatePhoto(photoId: String, location: Location?=nil, exif: Exif?=nil) -> UnsplashRequest<Photo.Serializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        var params : [String : AnyObject] = ["id" : photoId as AnyObject]
        if let l = location {
            var locationParams = [String : AnyObject]()
            if l.city != nil { locationParams["city"] = l.city as AnyObject }
            if l.country != nil { locationParams["country"] = l.country as AnyObject }
            if l.name != nil { locationParams["name"] = l.name as AnyObject }
            if (l.confidential != nil && l.confidential!) { locationParams["confidential"] = "true" as AnyObject }
            params["location"] = locationParams as AnyObject
        }
        if let e = exif {
            var exifParams = [String : AnyObject]()
            if e.make != nil { exifParams["make"] = e.make as AnyObject }
            if e.model != nil { exifParams["model"] = e.model as AnyObject }
            if e.exposureTime != nil { exifParams["exposure_time"] = NSNumber(value: e.exposureTime!) }
            if e.aperture != nil { exifParams["aperture_value"] = NSNumber(value: e.aperture!) }
            if e.focalLength != nil { exifParams["focal_length"] = NSNumber(value: e.focalLength!) }
            if e.iso != nil { exifParams["iso_speed_ratings"] = NSNumber(value: e.iso!) }
            params["exif"] = exifParams as AnyObject
        }
        return UnsplashRequest(client: self.client, method: .PUT, route: "/photos/\(photoId)", auth: true, params: params, responseSerializer: Photo.Serializer())
    }
    
    public func likePhoto(photoId: String) -> UnsplashRequest<PhotoUserResult.Serializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        let params = ["id" : photoId]
        return UnsplashRequest(client: self.client, method: .POST, route: "/photos/\(photoId)/like", auth: true, params: params, responseSerializer: PhotoUserResult.Serializer())
    }
    
    public func unlikePhoto(photoId: String) -> UnsplashRequest<DeleteResultSerializer> {
        precondition(client.authorized, "client is not authorized to make this request")
        
        let params = ["id" : photoId]
        return UnsplashRequest(client: self.client, method: .DELETE, route: "/photos/\(photoId)/like", auth: true, params: params, responseSerializer: DeleteResultSerializer())
    }
    
}
