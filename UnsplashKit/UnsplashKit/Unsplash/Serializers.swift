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
    typealias ValueType = JSONSerializer
    func deserialize(_: JSON) -> ValueType
}

public extension JSONSerializer {
    func deserialize(json: JSON?) -> ValueType? {
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
    public typealias ValueType = JSONSerializer
    
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
    var dateFormatter : DateFormatter
    
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }
    public func deserialize(json: JSON) -> NSDate {
        switch json {
        case .Str(let s):
            return self.dateFormatter.date(from: s)! as NSDate
        default:
            fatalError("Type error deserializing")
        }
    }
}

public class DeleteResultSerializer : JSONSerializer {
    public func deserialize(_: JSON) -> JSONSerializer.ValueType {
        
    }
    
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
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> User {
            switch json {
            case .Dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"]!)
                let username = StringSerializer().deserialize(dict["username"] ?? .Null)
                let name = StringSerializer().deserialize(dict["name"]!)
                let firstName = StringSerializer().deserialize(dict["first_name"]!)
                let lastName = StringSerializer().deserialize(dict["last_name"]!)
                let downloads = UInt32Serializer().deserialize(dict["downloads"]!)
                let profilePhoto = ProfilePhotoURL.Serializer().deserialize(json: dict["profile_image"])
                let portfolioURL = NSURLSerializer().deserialize(dict["portfolio_url"]!)
                let bio = StringSerializer().deserialize(dict["bio"]!)
                let uploadsRemaining = UInt32Serializer().deserialize(dict["uploads_remaining"]!)
                let instagramUsername = StringSerializer().deserialize(dict["instagram_username"]!)
                let location = StringSerializer().deserialize(dict["location"]!)
                let email = StringSerializer().deserialize(dict["email"]!)
                return User(id: id as? String,
                            username: username as! String,
                            name: name as? String,
                            firstName: firstName as? String,
                            lastName: lastName as? String,
                            downloads: downloads as? UInt32,
                            profilePhoto: profilePhoto as? ProfilePhotoURL ,
                            portfolioURL: portfolioURL  as? URL ,
                            bio: bio as? String,
                            uploadsRemaining: uploadsRemaining as? UInt32,
                            instagramUsername: instagramUsername as? String,
                            location: location as? String,
                            email: email as? String)
            default:
                fatalError("error deserializing")
            }
        }
        public func deserialize(_ json: JSON?) -> User? {
            if let j = json {
                return deserialize(j)
            }
            return nil
        }
    }
}
extension ProfilePhotoURL {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> ProfilePhotoURL {
            switch json {
            case .Dictionary(let dict):
                let large = NSURLSerializer().deserialize(dict["large"] ?? .Null)
                let medium = NSURLSerializer().deserialize(dict["medium"] ?? .Null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
                let custom = NSURLSerializer().deserialize(dict["custom"]!)
                return ProfilePhotoURL(large: large as! URL,
                                       medium: medium as! URL,
                                       small: small as! URL,
                                       custom: custom as? URL)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension CollectionsResult {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> CollectionsResult {
            switch json {
            case .Array:
                let collections = ArraySerializer(Collection.Serializer()).deserialize(json)
                return CollectionsResult(collections: collections as! Array<Collection>)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Collection {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(_ json: JSON) -> Collection {
            switch json {
            case .Dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
                let curated = BoolSerializer().deserialize(dict["curated"] ?? .Null)
                let coverPhoto = Photo.Serializer().deserialize(json: dict["cover_photo"] ?? .Null)
                let publishedAt = NSDateSerializer().deserialize(dict["published_at"] ?? .Null)
                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
                return Collection(id: id as! UInt32,
                                  title: title as! String,
                                  curated: curated as! Bool,
                                  coverPhoto: coverPhoto,
                                  publishedAt: publishedAt as! Date,
                                  user: user as! User)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotoCollectionResult {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        
        public init() {}
        public func deserialize(json: JSON) -> PhotoCollectionResult {
            switch json {
            case .Dictionary(let dict):
                let photo = Photo.Serializer().deserialize(json: dict["photo"] ?? .Null)
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
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> PhotoUserResult {
            switch json {
            case .Dictionary(let dict):
                let photo = Photo.Serializer().deserialize(json: dict["photo"] ?? .Null)
                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
                return PhotoUserResult(photo: photo, user: user as! User)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Photo {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Photo {
            switch json {
            case .Dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"] ?? .Null)
                let width = UInt32Serializer().deserialize(dict["width"]!)
                let height = UInt32Serializer().deserialize(dict["height"]!)
                let color = UIColorSerializer().deserialize(dict["color"]!)
                let user = User.Serializer().deserialize(dict["user"])
                let url = PhotoURL.Serializer().deserialize(json: dict["urls"] ?? .Null)
                let categories = ArraySerializer(Category.Serializer()).deserialize(dict["categories"]!)
                let exif = Exif.Serializer().deserialize(json: dict["exif"])
                let downloads = UInt32Serializer().deserialize(dict["downloads"]!)
                let likes = UInt32Serializer().deserialize(dict["likes"]!)
                let location = Location.Serializer().deserialize(json: dict["location"])
                return Photo(id: id as! String,
                             width: width as? UInt32,
                             height: height as? UInt32,
                             color: color as? UIColor,
                             user: user,
                             url: url,
                             categories: categories as? Array<Category>,
                             exif: exif as? Exif,
                             downloads: downloads as? UInt32,
                             likes: likes as? UInt32,
                             location: location as? Location)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotosResult {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> PhotosResult {
            switch json {
            case .Array:
                let photos = ArraySerializer(Photo.Serializer()).deserialize(json)
                return PhotosResult(photos: photos as! Array<Photo>)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension PhotoURL {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> PhotoURL {
            switch json {
            case .Dictionary(let dict):
                let full = NSURLSerializer().deserialize(dict["full"] ?? .Null)
                let regular = NSURLSerializer().deserialize(dict["regular"] ?? .Null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
                let thumb = NSURLSerializer().deserialize(dict["thumb"] ?? .Null)
                let custom = NSURLSerializer().deserialize(dict["custom"]!)
                return PhotoURL(full: full as! URL,
                                regular: regular as! URL,
                                small: small as! URL,
                                thumb: thumb as! URL,
                                custom: custom as? URL)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Exif {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Exif {
            switch json {
            case .Dictionary(let dict):
                let make = StringSerializer().deserialize(dict["make"]!)
                let model = StringSerializer().deserialize(dict["model"]!)
                let exposureTime = DoubleSerializer().deserialize(dict["exposure_time"]!)
                let aperture = DoubleSerializer().deserialize(dict["aperture"]!)
                let focalLength = UInt32Serializer().deserialize(dict["focal_length"]!)
                let iso = UInt32Serializer().deserialize(dict["iso"]!)
                return Exif(make: make as? String, model: model as? String, exposureTime: exposureTime as? Double, aperture: aperture as? Double, focalLength: focalLength as? UInt32, iso: iso as? UInt32)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Location {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Location {
            switch json {
            case .Dictionary(let dict):
                let position = Position.Serializer().deserialize(json: dict["position"] ?? .Null)
                let city = StringSerializer().deserialize(dict["city"] ?? .Null)
                let country = StringSerializer().deserialize(dict["country"] ?? .Null)
                return Location(city: city as? String, country: country as? String, position: position)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Position {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Position {
            switch json {
            case .Dictionary(let dict):
                let latitude = DoubleSerializer().deserialize(dict["latitude"] ?? .Null)
                let longitude = DoubleSerializer().deserialize(dict["longitude"] ?? .Null)
                return Position(latitude: latitude as! Double, longitude: longitude as! Double)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension CategoriesResult {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> CategoriesResult {
            switch json {
            case .Array:
                let categories = ArraySerializer(Category.Serializer()).deserialize(json)
                return CategoriesResult(categories: categories as! Array<Category>)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Category {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Category {
            switch json {
            case .Dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
                let photoCount = UInt32Serializer().deserialize(dict["photo_count"] ?? .Null)
                return Category(id: id as! UInt32, title: title as! String, photoCount: photoCount as! UInt32)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Stats {
    public class Serializer : JSONSerializer {
        public func deserialize(_: JSON) -> JSONSerializer.ValueType {
            
        }
        
        public init() {}
        public func deserialize(json: JSON) -> Stats {
            switch json {
            case .Dictionary(let dict):
                let photoDownloads = UInt32Serializer().deserialize(dict["photo_downloads"] ?? .Null)
                let batchDownloads = UInt32Serializer().deserialize(dict["batch_downloads"] ?? .Null)
                return Stats(photoDownloads: photoDownloads as! UInt32, batchDownloads: batchDownloads as! UInt32)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
