//
//  Models.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit

public class User {
    public let id: String
    public let updatedAt: String
    public let username: String
    public let name: String
    public let firstName: String
    public let lastName: String?
    public let twitterUsername: String?
    public let instagramUsername: String?
    public let portfolioUrl: URL?
    public let bio: String?
    public let location: String?
    public let totalLikes: Int
    public let totalPhotos: Int
    public let totalCollections: Int
    
    
    public let profileImage: ProfilePhotoURL
    public let links: Links
    public init(id: String, updatedAt: String, username: String, name: String, firstName: String, lastName: String?, twitterUsername: String?, instagramUsername: String?, portfolioUrl: URL?, bio: String?, location: String?, totalLikes: Int, totalPhotos: Int, totalCollections: Int, profileImage: ProfilePhotoURL, links: Links) {
        self.id = id
        self.updatedAt = updatedAt
        self.username = username
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.twitterUsername = twitterUsername
        self.instagramUsername = instagramUsername
        self.portfolioUrl = portfolioUrl
        self.bio = bio
        self.location = location
        self.totalLikes = totalLikes
        self.totalPhotos = totalPhotos
        self.totalCollections = totalCollections
        self.profileImage = profileImage
        self.links = links
    }
    

}

public class Links {
    public let user: URL  // 'self -> user'
    public let html: URL
    public let download: URL
    public let downloadLocation: URL
    public init(user: URL, html: URL, download: URL, downloadLocation: URL) {
        self.user = user
        self.html = html
        self.download = download
        self.downloadLocation = downloadLocation
    }
}


public class ProfilePhotoURL {
    public let small: URL
    public let medium: URL
    public let large: URL
    public init(small: URL, medium: URL, large: URL) {
        self.small = small
        self.medium = medium
        self.large = large
    }
}
public class CollectionsResult {
    public let collections : Array<Collection>
    
    public init(collections: Array<Collection>) {
        self.collections = collections
    }
}
public class Collection {
    public let id : UInt32
    public let title : String
    public let curated : Bool
    public let coverPhoto : Photo
    public let publishedAt : Date
    public let user : User
    
    public init(id: UInt32,
                title: String,
                curated: Bool,
                coverPhoto: Photo,
                publishedAt: Date,
                user: User) {
        
        self.id = id
        self.publishedAt = publishedAt
        self.user = user
        self.title = title
        self.curated = curated
        self.coverPhoto = coverPhoto
    }
}
public class PhotoCollectionResult {
    public let photo : Photo
    public let collection : Collection
    
    public init(photo: Photo, collection: Collection) {
        self.photo = photo
        self.collection = collection
    }
}

public class PhotoUserResult {
    public let photo : Photo
    public let user : User
    
    public init(photo: Photo, user: User) {
        self.photo = photo
        self.user = user
    }
}
public class PhotosResult {
    public let photos : Array<Photo>
    
    public init(photos: Array<Photo>) {
        self.photos = photos
    }
}


public class Photo {
    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let width: Int
    public let height: Int
    public let color: UIColor
    public let likes: Int
    public let likedByUser: Bool
    public let description: Any?
    public let sponsored: Bool
    
    public let user: User
    public let currentUserCollections: [Any]
    
    public let urls: PhotoURL
    public let categories: [Any]
    
    public let links: Links
    
    public init(id: String, createdAt: String, updatedAt: String, width: Int, height: Int, color: UIColor, likes: Int, likedByUser: Bool, description: Any?, sponsored: Bool, user: User, currentUserCollections: [Any], urls: PhotoURL, categories: [Any], links: Links) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.width = width
        self.height = height
        self.color = color
        self.likes = likes
        self.likedByUser = likedByUser
        self.description = description
        self.sponsored = sponsored
        self.user = user
        self.currentUserCollections = currentUserCollections
        self.urls = urls
        self.categories = categories
        self.links = links
    }
    
}


public class PhotoURL {
    public let raw: URL
    public let full: URL
    public let regular: URL
    public let small: URL
    public let thumb: URL
    public init(raw: URL, full: URL, regular: URL, small: URL, thumb: URL) {
        self.raw = raw
        self.full = full
        self.regular = regular
        self.small = small
        self.thumb = thumb
    }
}
public class CategoriesResult {
    public let categories : Array<Category>
    
    public init(categories: Array<Category>) {
        self.categories = categories
    }
}
public class Category {
    public let id : UInt32
    public let title : String
    public let photoCount : UInt32
    
    public init(id: UInt32, title: String, photoCount: UInt32) {
        self.id = id
        self.title = title
        self.photoCount = photoCount
    }
}
public class Stats {
    public let photoDownloads : UInt32
    public let batchDownloads : UInt32
    public init(photoDownloads: UInt32, batchDownloads: UInt32) {
        self.photoDownloads = photoDownloads
        self.batchDownloads = batchDownloads
    }
}
public class Exif {
    public let make : String?
    public let model : String?
    public let exposureTime : Double?
    public let aperture : Double?
    public let focalLength : UInt32?
    public let iso : UInt32?
    public init(make: String?,
                model: String?,
                exposureTime: Double?,
                aperture: Double?,
                focalLength: UInt32?,
                iso: UInt32?) {
        self.make = make
        self.model = model
        self.exposureTime = exposureTime
        self.aperture = aperture
        self.focalLength = focalLength
        self.iso = iso
    }
}
public class Location {
    public let city: String?
    public let country: String?
    public let positon: Position?
    public let name : String?
    public let confidential : Bool?
    public init(city: String?=nil,
                country: String?=nil,
                position: Position?=nil,
                name: String?=nil,
                confidential: Bool?=nil) {
        self.city = city
        self.country = country
        self.positon = position
        self.name = name
        self.confidential = confidential
    }
}
public class Position {
    public let latitude : Double
    public let longitude : Double
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
