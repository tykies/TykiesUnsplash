//
//  Serializers.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit
import CoreGraphics

// TODO: Create struct to hold single instance for all serializers.

public enum JSON {
    case Array([JSON])
    case Dictionary([String: JSON])
    case Str(String)
    case Number(NSNumber)
    case Null
}

public protocol JSONSerializer {
    associatedtype ValueType
    func deserialize(_ json: JSON?) -> ValueType?
}

public extension JSONSerializer {
    func deserialize(_ json: JSON?) -> ValueType? {
        if let j = json {
            switch j {
            case .Null:
                return nil
            default:
                return deserialize(j)
            }
        }
        return nil
    }
}

func objectToJSON(_ json : AnyObject) -> JSON {
    
    switch json {
    case _ as NSNull:
        return .Null
    case let num as NSNumber:
        return .Number(num)
    case let str as String:
        return .Str(str)
    case let dict as [String : AnyObject]:
        var ret = [String : JSON]()
        for (k, v) in dict {
            ret[k] = objectToJSON(v)
        }
        return .Dictionary(ret)
    case let array as [AnyObject]:
        return .Array(array.map(objectToJSON))
    default:
        fatalError("Unknown type trying to parse JSON.")
    }
}

func parseJSON(data: Data) -> JSON {
    let obj: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
    return objectToJSON(obj)
}

// MARK: - Common Serializers
public class ArraySerializer<T : JSONSerializer> : JSONSerializer {
   
    var elementSerializer : T

    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }

    public func deserialize(json : JSON) -> Array<T.ValueType> {
        switch json {
        case .Array(let arr):
            return arr.map { self.elementSerializer.deserialize($0) }
        default:
            fatalError("Type error deserializing")
        }
    }
}


public class UInt32Serializer : JSONSerializer {
    public typealias ValueType = UInt32
    
    public func deserialize(json : JSON) -> UInt32 {
        switch json {
        case .Number(let n):
            return n.uint32Value
        default:
            fatalError("Type error deserializing")
        }
    }
    public func deserialize(json: JSON?) -> UInt32? {
        if let j = json {
            switch(j) {
            case .Number(let n):
                return n.uint32Value
            default:
                break
            }
        }
        return nil
    }
}
public class BoolSerializer : JSONSerializer {
    public func deserialize(json : JSON) -> Bool {
        switch json {
        case .Number(let b):
            return b.boolValue
        default:
            fatalError("Type error deserializing")
        }
    }
}
public class DoubleSerializer : JSONSerializer {
    public func deserialize(json: JSON) -> Double {
        switch json {
        case .Number(let n):
            return n.doubleValue
        default:
            fatalError("Type error deserializing")
        }
    }
    public func deserialize(json: JSON?) -> Double? {
        if let j = json {
            switch(j) {
            case .Number(let n):
                return n.doubleValue
            default:
                break
            }
        }
        return nil
    }
}
public class StringSerializer : JSONSerializer {
    public func deserialize(json: JSON) -> String {
        switch (json) {
        case .Str(let s):
            return s
        default:
            fatalError("Type error deserializing")
        }
    }
}
// Color comes in the following format: #000000
public class UIColorSerializer : JSONSerializer {
    public func deserialize(json: JSON) -> UIColor {
        switch (json) {
        case .Str(let s):
            return UIColor.colorWithHexString(s)
        default:
            fatalError("Type error deserializing")
        }
    }
}
public class NSURLSerializer : JSONSerializer {
    public func deserialize(json: JSON) -> NSURL {
        switch (json) {
        case .Str(let s):
            return NSURL(string: s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}
// Date comes in the following format: 2015-06-17T11:53:00-04:00
public class NSDateSerializer : JSONSerializer {
    var dateFormatter : NSDateFormatter
    
    init() {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }
    public func deserialize(json: JSON) -> NSDate {
        switch json {
        case .Str(let s):
            return self.dateFormatter.dateFromString(s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}

public class DeleteResultSerializer : JSONSerializer {

    
    public typealias ValueType = Bool

    init(){}
    public func deserialize(json: JSON) -> Bool {
        switch json {
        case .Null:
            return true
        default:
            fatalError("Type error deserializing")
        }
    }
}

// MARK: Model Serializers
extension User {
    public class Serializer : JSONSerializer {
        public typealias ValueType = User
        
        public init() {}
        public func deserialize(json: JSON) -> User {
            switch json {
            case .Dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"])
                let username = StringSerializer().deserialize(dict["username"] ?? .Null)
                let name = StringSerializer().deserialize(dict["name"])
                let firstName = StringSerializer().deserialize(dict["first_name"])
                let lastName = StringSerializer().deserialize(dict["last_name"])
                let downloads = UInt32Serializer().deserialize(dict["downloads"])
                let profilePhoto = ProfilePhotoURL.Serializer().deserialize(dict["profile_image"])
                let portfolioURL = NSURLSerializer().deserialize(dict["portfolio_url"])
                let bio = StringSerializer().deserialize(dict["bio"])
                let uploadsRemaining = UInt32Serializer().deserialize(dict["uploads_remaining"])
                let instagramUsername = StringSerializer().deserialize(dict["instagram_username"])
                let location = StringSerializer().deserialize(dict["location"])
                let email = StringSerializer().deserialize(dict["email"])
                return User(id: id, username: username, name: name, firstName: firstName, lastName: lastName, downloads: downloads, profilePhoto: profilePhoto, portfolioURL: portfolioURL, bio: bio, uploadsRemaining: uploadsRemaining, instagramUsername: instagramUsername, location: location, email: email)
            default:
                fatalError("error deserializing")
            }
        }
        public func deserialize(json: JSON?) -> User? {
            if let j = json {
                return deserialize(j)
            }
            return nil
        }
    }
}
extension ProfilePhotoURL {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> ProfilePhotoURL {
            switch json {
            case .Dictionary(let dict):
                let large = NSURLSerializer().deserialize(dict["large"] ?? .Null)
                let medium = NSURLSerializer().deserialize(dict["medium"] ?? .Null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
                let custom = NSURLSerializer().deserialize(dict["custom"])
                return ProfilePhotoURL(large: large, medium: medium, small: small, custom: custom)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension CollectionsResult {
    public class Serializer : JSONSerializer {
        public typealias ValueType = CollectionsResult
        
        public init() {}
        public func deserialize(json: JSON) -> CollectionsResult {
            switch json {
            case .Array:
                let collections = ArraySerializer(Collection.Serializer()).deserialize(json)
                return CollectionsResult(collections: collections)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Collection {
    public class Serializer : JSONSerializer {
        public typealias ValueType = Collection
        
        public init() {}
        public func deserialize(json: JSON) -> Collection {
            switch json {
            case .Dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
                let curated = BoolSerializer().deserialize(dict["curated"] ?? .Null)
                let coverPhoto = Photo.Serializer().deserialize(dict["cover_photo"] ?? .Null)
                let publishedAt = NSDateSerializer().deserialize(dict["published_at"] ?? .Null)
                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
                return Collection(id: id, title: title, curated: curated, coverPhoto: coverPhoto, publishedAt: publishedAt, user: user)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotoCollectionResult {
    public class Serializer : JSONSerializer {
       
        public typealias ValueType = PhotoCollectionResult
        
        public init() {}
        public func deserialize(json: JSON) -> PhotoCollectionResult {
            switch json {
            case .Dictionary(let dict):
                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .Null)
                let collection = Collection.Serializer().deserialize(dict["collection"] ?? .Null)
                return PhotoCollectionResult(photo: photo, collection: collection)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotoUserResult {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> PhotoUserResult {
            switch json {
            case .Dictionary(let dict):
                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .Null)
                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
                return PhotoUserResult(photo: photo, user: user)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Photo {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> Photo {
            switch json {
            case .Dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"] ?? .Null)
                let width = UInt32Serializer().deserialize(dict["width"])
                let height = UInt32Serializer().deserialize(dict["height"])
                let color = UIColorSerializer().deserialize(dict["color"])
                let user = User.Serializer().deserialize(dict["user"])
                let url = PhotoURL.Serializer().deserialize(dict["urls"] ?? .Null)
                let categories = ArraySerializer(Category.Serializer()).deserialize(dict["categories"])
                let exif = Exif.Serializer().deserialize(dict["exif"])
                let downloads = UInt32Serializer().deserialize(dict["downloads"])
                let likes = UInt32Serializer().deserialize(dict["likes"])
                let location = Location.Serializer().deserialize(dict["location"])
                return Photo(id: id, width: width, height: height, color: color, user: user, url: url, categories: categories, exif: exif, downloads: downloads, likes: likes, location: location)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotosResult {
    public class Serializer : JSONSerializer {
        public typealias ValueType = PhotosResult
        
        public init() {}
        public func deserialize(json: JSON) -> PhotosResult {
            switch json {
            case .Array:
                let photos = ArraySerializer(Photo.Serializer()).deserialize(json)
                return PhotosResult(photos: photos)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotoURL {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> PhotoURL {
            switch json {
            case .Dictionary(let dict):
                let full = NSURLSerializer().deserialize(dict["full"] ?? .Null)
                let regular = NSURLSerializer().deserialize(dict["regular"] ?? .Null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
                let thumb = NSURLSerializer().deserialize(dict["thumb"] ?? .Null)
                let custom = NSURLSerializer().deserialize(dict["custom"])
                return PhotoURL(full: full, regular: regular, small: small, thumb: thumb, custom: custom)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Exif {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> Exif {
            switch json {
            case .Dictionary(let dict):
                let make = StringSerializer().deserialize(dict["make"])
                let model = StringSerializer().deserialize(dict["model"])
                let exposureTime = DoubleSerializer().deserialize(dict["exposure_time"])
                let aperture = DoubleSerializer().deserialize(dict["aperture"])
                let focalLength = UInt32Serializer().deserialize(dict["focal_length"])
                let iso = UInt32Serializer().deserialize(dict["iso"])
                return Exif(make: make, model: model, exposureTime: exposureTime, aperture: aperture, focalLength: focalLength, iso: iso)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Location {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> Location {
            switch json {
            case .Dictionary(let dict):
                let position = Position.Serializer().deserialize(dict["position"] ?? .Null)
                let city = StringSerializer().deserialize(dict["city"] ?? .Null)
                let country = StringSerializer().deserialize(dict["country"] ?? .Null)
                return Location(city: city, country: country, position: position)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Position {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(json: JSON) -> Position {
            switch json {
            case .Dictionary(let dict):
                let latitude = DoubleSerializer().deserialize(dict["latitude"] ?? .Null)
                let longitude = DoubleSerializer().deserialize(dict["longitude"] ?? .Null)
                return Position(latitude: latitude, longitude: longitude)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension CategoriesResult {
    public class Serializer : JSONSerializer {
        public typealias ValueType = CategoriesResult
        
        public init() {}
        public func deserialize(json: JSON) -> CategoriesResult {
            switch json {
            case .Array:
                let categories = ArraySerializer(Category.Serializer()).deserialize(json)
                return CategoriesResult(categories: categories)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Category {
    public class Serializer : JSONSerializer {
        public typealias ValueType = Category
        
        public init() {}
        public func deserialize(json: JSON) -> Category {
            switch json {
            case .Dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
                let photoCount = UInt32Serializer().deserialize(dict["photo_count"] ?? .Null)
                return Category(id: id, title: title, photoCount: photoCount)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Stats {
    public class Serializer : JSONSerializer {
        public typealias ValueType = Stats
        
        public init() {}
        public func deserialize(json: JSON) -> Stats {
            switch json {
            case .Dictionary(let dict):
                let photoDownloads = UInt32Serializer().deserialize(dict["photo_downloads"] ?? .Null)
                let batchDownloads = UInt32Serializer().deserialize(dict["batch_downloads"] ?? .Null)
                return Stats(photoDownloads: photoDownloads, batchDownloads: batchDownloads)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
