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
    case array([JSON])
    case dictionary([String: JSON])
    case str(String)
    case number(NSNumber)
    case null
}

open class SerializeUtil {
    open class func objectToJSON(_ json: AnyObject) -> JSON {
        
        switch json {
        case _ as NSNull:
            return .null
        case let num as NSNumber:
            return .number(num)
        case let str as String:
            return .str(str)
        case let dict as [String: AnyObject]:
            var ret = [String: JSON]()
            for (k, v) in dict {
                ret[k] = objectToJSON(v)
            }
            return .dictionary(ret)
        case let array as [AnyObject]:
            return .array(array.map(objectToJSON))
        default:
            fatalError("Unknown type trying to parse JSON.")
        }
    }
    
    open class func prepareJSONForSerialization(_ json: JSON) -> AnyObject {
        switch json {
        case .array(let array):
            return array.map(prepareJSONForSerialization) as AnyObject
        case .dictionary(let dict):
            var ret = [String: AnyObject]()
            for (k, v) in dict {
                // kind of a hack...
                switch v {
                case .null:
                    continue
                default:
                    ret[k] = prepareJSONForSerialization(v)
                }
            }
            return ret as AnyObject
        case .number(let n):
            return n
        case .str(let s):
            return s as AnyObject
        case .null:
            return NSNull()
        }
    }
    
    open class func dumpJSON(_ json: JSON) -> Data? {
        switch json {
        case .null:
            return "null".data(using: String.Encoding.utf8, allowLossyConversion: false)
        default:
            let obj: AnyObject = prepareJSONForSerialization(json)
            if JSONSerialization.isValidJSONObject(obj) {
                return try! JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions())
            } else {
                fatalError("Invalid JSON toplevel type")
            }
        }
    }
    
    open class func parseJSON(_ data: Data) -> JSON {
        let obj: AnyObject = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
        return objectToJSON(obj)
    }
}


public protocol JSONSerializer {
    associatedtype ValueType
//    func serialize(_: ValueType) -> JSON
    func deserialize(_: JSON) -> ValueType
}

open class VoidSerializer: JSONSerializer {
    open func serialize(_ value: Void) -> JSON {
        return .null
    }
    
    open func deserialize(_ json: JSON) -> Void {
        switch json {
        case .null:
            return
        default:
            fatalError("Type error deserializing")
        }
        
    }
}

// MARK: - Common Serializers
open class ArraySerializer<T : JSONSerializer> : JSONSerializer {
    
    var elementSerializer : T
    
    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }
    
//    open func serialize(_ arr: Array<T.ValueType>) -> JSON {
//        return .array(arr.map { self.elementSerializer.serialize($0) })
//    }
    
    public func deserialize(_ json : JSON) -> Array<T.ValueType> {
        switch json {
        case .array(let arr):
            return arr.map { self.elementSerializer.deserialize($0) }
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class UInt64Serializer: JSONSerializer {
    open func serialize(_ value: UInt64) -> JSON {
        return .number(NSNumber(value: value as UInt64))
    }
    
    open func deserialize(_ json: JSON) -> UInt64 {
        switch json {
        case .number(let n):
            return n.uint64Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class Int64Serializer: JSONSerializer {
    open func serialize(_ value: Int64) -> JSON {
        return .number(NSNumber(value: value as Int64))
    }
    
    open func deserialize(_ json: JSON) -> Int64 {
        switch json {
        case .number(let n):
            return n.int64Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class Int32Serializer: JSONSerializer {
    open func serialize(_ value: Int32) -> JSON {
        return .number(NSNumber(value: value as Int32))
    }
    
    open func deserialize(_ json: JSON) -> Int32 {
        switch json {
        case .number(let n):
            return n.int32Value
        default:
            fatalError("Type error deserializing")
        }
    }
}
open class UInt32Serializer: JSONSerializer {
    open func serialize(_ value: UInt32) -> JSON {
        return .number(NSNumber(value: value as UInt32))
    }
    
    open func deserialize(_ json: JSON) -> UInt32 {
        switch json {
        case .number(let n):
            return n.uint32Value
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class BoolSerializer: JSONSerializer {
    open func serialize(_ value: Bool) -> JSON {
        return .number(NSNumber(value: value as Bool))
    }
    open func deserialize(_ json: JSON) -> Bool {
        switch json {
        case .number(let b):
            return b.boolValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class NSDataSerializer: JSONSerializer {
    open func serialize(_ value: Data) -> JSON {
        return .str(value.base64EncodedString(options: []))
    }
    
    open func deserialize(_ json: JSON) -> Data {
        switch(json) {
        case .str(let s):
            return Data(base64Encoded: s, options: [])!
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class DoubleSerializer: JSONSerializer {
    open func serialize(_ value: Double) -> JSON {
        return .number(NSNumber(value: value as Double))
    }
    
    open func deserialize(_ json: JSON) -> Double {
        switch json {
        case .number(let n):
            return n.doubleValue
        default:
            fatalError("Type error deserializing")
        }
    }
}

open class StringSerializer: JSONSerializer {
    open func serialize(_ value: String) -> JSON {
        return .str(value)
    }
    
    open func deserialize(_ json: JSON) -> String {
        switch (json) {
        case .str(let s):
            return s
        default:
            fatalError("Type error deserializing")
        }
    }
}

// Color comes in the following format: #000000
open class UIColorSerializer : JSONSerializer {
//    open func serialize(_ value: UIColor) -> JSON {
//        return .number(NSNumber())
//    }
    
    public func deserialize(_ json: JSON) -> UIColor {
        switch (json) {
        case .str(let s):
            return UIColor.colorWithHexString(s)
        default:
            fatalError("Type error deserializing")
        }
    }
}
public class NSURLSerializer : JSONSerializer {
    public func deserialize(_ json: JSON) -> URL {
        switch (json) {
        case .str(let s):
            return URL(string: s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}

public class NSDateSerializer : JSONSerializer {
    var dateFormatter : DateFormatter
    
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    }
    public func deserialize(_ json: JSON) -> Date {
        switch json {
        case .str(let s):
            return self.dateFormatter.date(from: s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}
public class DeleteResultSerializer : JSONSerializer {
    init(){}
    public func deserialize(_ json: JSON) -> Bool {
        switch json {
        case .null:
            return true
        default:
            fatalError("Type error deserializing")
        }
    }
}

// MARK: Model Serializers
extension User {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> User {
            switch json {
            case .dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"]!)
                let username = StringSerializer().deserialize(dict["username"] ?? .null)
                let name = StringSerializer().deserialize(dict["name"]!)
                let firstName = StringSerializer().deserialize(dict["first_name"]!)
                let lastName = StringSerializer().deserialize(dict["last_name"]!)
//                let downloads = UInt32Serializer().deserialize((dict["downloads"])!)
                let profilePhoto = ProfilePhotoURL.Serializer().deserialize(dict["profile_image"]!)
//                let portfolioURL = NSURLSerializer().deserialize(dict["portfolio_url"]!)
                let bio = StringSerializer().deserialize(dict["bio"]!)
//                let uploadsRemaining = UInt32Serializer().deserialize(dict["uploads_remaining"]!)
//                let instagramUsername = StringSerializer().deserialize(dict["instagram_username"]!)
                let location = StringSerializer().deserialize(dict["location"]!)
//                let email = StringSerializer().deserialize(dict["email"]!)
                return User(id: id, username: username, name: name, firstName: firstName, lastName: lastName, downloads: nil, profilePhoto: profilePhoto, portfolioURL: nil, bio: bio, uploadsRemaining: nil, instagramUsername: nil, location: location, email: nil)
            default:
                fatalError("error deserializing")
            }
        }
        
    }
}

extension ProfilePhotoURL {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> ProfilePhotoURL {
            switch json {
            case .dictionary(let dict):
                let large = NSURLSerializer().deserialize(dict["large"] ?? .null)
                let medium = NSURLSerializer().deserialize(dict["medium"] ?? .null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .null)
//                let custom = NSURLSerializer().deserialize(dict["custom"]!)
                return ProfilePhotoURL(large: large, medium: medium, small: small)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension CollectionsResult {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> CollectionsResult {
            switch json {
            case .array:
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
        public init() {}
        public func deserialize(_ json: JSON) -> Collection {
            switch json {
            case .dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .null)
                let title = StringSerializer().deserialize(dict["title"] ?? .null)
                let curated = BoolSerializer().deserialize(dict["curated"] ?? .null)
                let coverPhoto = Photo.Serializer().deserialize(dict["cover_photo"] ?? .null)
                let publishedAt = NSDateSerializer().deserialize(dict["published_at"] ?? .null)
                let user = User.Serializer().deserialize(dict["user"] ?? .null)
                return Collection(id: id, title: title, curated: curated, coverPhoto: coverPhoto, publishedAt: publishedAt, user: user)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension PhotoCollectionResult {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> PhotoCollectionResult {
            switch json {
            case .dictionary(let dict):
                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .null)
                let collection = Collection.Serializer().deserialize(dict["collection"] ?? .null)
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
        public func deserialize(_ json: JSON) -> PhotoUserResult {
            switch json {
            case .dictionary(let dict):
                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .null)
                let user = User.Serializer().deserialize(dict["user"] ?? .null)
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
        public func deserialize(_ json: JSON) -> Photo {
            switch json {
            case .dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"] ?? .null)
                let width = UInt32Serializer().deserialize(dict["width"]!)
                let height = UInt32Serializer().deserialize(dict["height"]!)
                let color = UIColorSerializer().deserialize(dict["color"]!)
                let user = User.Serializer().deserialize(dict["user"]!)
                let url = PhotoURL.Serializer().deserialize(dict["urls"] ?? .null)
                let categories = ArraySerializer(Category.Serializer()).deserialize(dict["categories"]!)
                let exif = Exif.Serializer().deserialize(dict["exif"]!)
                let downloads = UInt32Serializer().deserialize(dict["downloads"]!)
                let likes = UInt32Serializer().deserialize(dict["likes"]!)
                let location = Location.Serializer().deserialize(dict["location"]!)
                return Photo(id: id, width: width, height: height, color: color, user: user, url: url, categories: categories, exif: exif, downloads: downloads, likes: likes, location: location)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension PhotosResult {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> PhotosResult {
            switch json {
            case .array:
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
        public func deserialize(_ json: JSON) -> PhotoURL {
            switch json {
            case .dictionary(let dict):
                let full = NSURLSerializer().deserialize(dict["full"] ?? .null)
                let regular = NSURLSerializer().deserialize(dict["regular"] ?? .null)
                let small = NSURLSerializer().deserialize(dict["small"] ?? .null)
                let thumb = NSURLSerializer().deserialize(dict["thumb"] ?? .null)
//                let custom = NSURLSerializer().deserialize(dict["custom"]!)
                return PhotoURL(full: full, regular: regular, small: small, thumb: thumb, custom: nil)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension Exif {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> Exif {
            switch json {
            case .dictionary(let dict):
                let make = StringSerializer().deserialize(dict["make"]!)
                let model = StringSerializer().deserialize(dict["model"]!)
                let exposureTime = DoubleSerializer().deserialize(dict["exposure_time"]!)
                let aperture = DoubleSerializer().deserialize(dict["aperture"]!)
                let focalLength = UInt32Serializer().deserialize(dict["focal_length"]!)
                let iso = UInt32Serializer().deserialize(dict["iso"]!)
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
        public func deserialize(_ json: JSON) -> Location {
            switch json {
            case .dictionary(let dict):
                let position = Position.Serializer().deserialize(dict["position"] ?? .null)
                let city = StringSerializer().deserialize(dict["city"] ?? .null)
                let country = StringSerializer().deserialize(dict["country"] ?? .null)
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
        public func deserialize(_ json: JSON) -> Position {
            switch json {
            case .dictionary(let dict):
                let latitude = DoubleSerializer().deserialize(dict["latitude"] ?? .null)
                let longitude = DoubleSerializer().deserialize(dict["longitude"] ?? .null)
                return Position(latitude: latitude, longitude: longitude)
            default:
                fatalError("error deserializing")
            }
        }
    }
}


extension CategoriesResult {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> CategoriesResult {
            switch json {
            case .array:
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
        public init() {}
        public func deserialize(_ json: JSON) -> Category {
            switch json {
            case .dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .null)
                let title = StringSerializer().deserialize(dict["title"] ?? .null)
                let photoCount = UInt32Serializer().deserialize(dict["photo_count"] ?? .null)
                return Category(id: id, title: title, photoCount: photoCount)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
extension Stats {
    public class Serializer : JSONSerializer {
        public init() {}
        public func deserialize(_ json: JSON) -> Stats {
            switch json {
            case .dictionary(let dict):
                let photoDownloads = UInt32Serializer().deserialize(dict["photo_downloads"] ?? .null)
                let batchDownloads = UInt32Serializer().deserialize(dict["batch_downloads"] ?? .null)
                return Stats(photoDownloads: photoDownloads, batchDownloads: batchDownloads)
            default:
                fatalError("error deserializing")
            }
        }
    }
}
