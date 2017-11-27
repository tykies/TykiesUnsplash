//
//  CollectionsRoutes.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class CollectionsRoutes {
    
    
    let client : UnsplashClient
    
    public init(client: UnsplashClient) {
        self.client = client
    }
    
    public func findCollections(page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<CollectionsResult.Serializer> {
        var params = [String : AnyObject]()
        if let page = page {
            params["page"] = NSNumber(value: page)
        }
        if let perPage = perPage {
            params["per_page"] = NSNumber(value: perPage)
        }
        return UnsplashRequest(client: self.client, route: "/collections", auth: false, params: params, responseSerializer: CollectionsResult.Serializer())
    }
    
    public func findCuratedCollections(page: UInt32?=nil, perPage: UInt32?=nil) -> UnsplashRequest<CollectionsResult.Serializer> {
        var params = [String : AnyObject]()
        if let page = page {
            params["page"] = NSNumber(value: page)
        }
        if let perPage = perPage {
            params["per_page"] = NSNumber(value: perPage)
        }
        return UnsplashRequest(client: self.client, route: "/collections/curated", auth: false, params: params, responseSerializer: CollectionsResult.Serializer())
    }
    
    public func findCollection(collectionId: UInt32) -> UnsplashRequest<Collection.Serializer> {
        let params = ["id" : NSNumber(value: collectionId)]
        return UnsplashRequest(client: self.client, route: "/collections/\(collectionId)", auth: false, params: params, responseSerializer: Collection.Serializer())
    }
    
    public func findCuratedCollection(collectionId: UInt32) -> UnsplashRequest<Collection.Serializer> {
        let params = ["id" : NSNumber(value: collectionId)]
        return UnsplashRequest(client: self.client, route: "/collections/curatd/\(collectionId)", auth: false, params: params, responseSerializer: Collection.Serializer())
    }
    
    public func photosForCollection(collectionId: UInt32) -> UnsplashRequest<PhotosResult.Serializer> {
        let params = ["id" : NSNumber(value: collectionId)]
        return UnsplashRequest(client: self.client, route: "/collections/\(collectionId)/photos", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
    public func photosForCuratedCollection(collectionId: UInt32) -> UnsplashRequest<PhotosResult.Serializer> {
        let params = ["id" : NSNumber(value: collectionId)]
        return UnsplashRequest(client: self.client, route: "/collections/curated/\(collectionId)/photos", auth: false, params: params, responseSerializer: PhotosResult.Serializer())
    }
    
    public func createCollection(title: String, description: String?=nil, isPrivate: Bool=false ) -> UnsplashRequest<Collection.Serializer> {
        var params : [String : AnyObject] = ["title" : title as AnyObject]
        if let d = description {
            params["description"] = d as AnyObject
        }
        if isPrivate {
            params["private"] = "true" as AnyObject
        }
        return UnsplashRequest(client: self.client, method: .post, route: "/collections", auth: true, params: params, responseSerializer: Collection.Serializer())
    }
    
    public func updateCollection(collectionId: UInt32, title: String?=nil, description: String?=nil, isPrivate: Bool=false) -> UnsplashRequest<Collection.Serializer> {
        var params : [String : AnyObject] = ["id" : NSNumber(value: collectionId)]
        if let t = title {
            params["title"] = t as AnyObject
        }
        if let d = description {
            params["description"] = d as AnyObject
        }
        if isPrivate {
            params["private"] = "true" as AnyObject
        }
        return UnsplashRequest(client: self.client, method: .put, route: "/collections/\(collectionId)", auth: true, params: params, responseSerializer: Collection.Serializer())
    }
    
    public func deleteCollection(collectionId: UInt32) -> UnsplashRequest<DeleteResultSerializer> {
        let params = ["id" : NSNumber(value: collectionId)]
        return UnsplashRequest(client: self.client, method: .delete, route: "/collections/\(collectionId)", auth: true, params: params, responseSerializer: DeleteResultSerializer())
    }
    
    public func addPhotoToCollection(collectionId: UInt32, photoId: String) -> UnsplashRequest<PhotoCollectionResult.Serializer> {
        let params = [
            "collection_id" : NSNumber(value: collectionId),
            "photo_id" : photoId
            ] as [String : AnyObject]
        return UnsplashRequest(client: self.client, method: .post, route: "/collections/\(collectionId)/add", auth: true, params: params, responseSerializer: PhotoCollectionResult.Serializer())
    }
    
    public func removePhotoToCollection(collectionId: UInt32, photoId: UInt32) -> UnsplashRequest<DeleteResultSerializer> {
        let params = [
            "collection_id" : NSNumber(value: collectionId),
            "photo_id" : NSNumber(value: photoId)
        ]
        return UnsplashRequest(client: self.client, method: .delete, route: "/collections/\(collectionId)/remove", auth: true, params: params, responseSerializer: DeleteResultSerializer())
    }
    
}
