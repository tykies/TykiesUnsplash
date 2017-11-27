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
    func serialize(_: ValueType) -> JSON
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
open  class ArraySerializer<T : JSONSerializer> : JSONSerializer {
    
    var elementSerializer: T
    
    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }
    
    open func serialize(_ arr: Array<T.ValueType>) -> JSON {
        return .array(arr.map { self.elementSerializer.serialize($0) })
    }
    
    open func deserialize(_ json: JSON) -> Array<T.ValueType> {
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
public class BoolSerializer : JSONSerializer {
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

open class NullableSerializer<T: JSONSerializer>: JSONSerializer {
    
    var internalSerializer: T
    
    init(_ serializer: T) {
        self.internalSerializer = serializer
    }
    
    open func serialize(_ value: Optional<T.ValueType>) -> JSON {
        if let v = value {
            return internalSerializer.serialize(v)
        } else {
            return .null
        }
    }
    
    open func deserialize(_ json: JSON) -> Optional<T.ValueType> {
        switch json {
        case .null:
            return nil
        default:
            return internalSerializer.deserialize(json)
        }
    }
}
public class StringSerializer : JSONSerializer {
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
public class UIColorSerializer : JSONSerializer {
    
    open func serialize(_ value: UIColor) -> JSON {
        return .str(value as String)
    }
    
    open func deserialize(_ json: JSON) -> UIColorSerializer.ValueType {
        switch json {
        case: .str(let s)
            return UIColor.colorWithHexString(s)
        default:
            fatalError("Type error deserializing")
        }
    }
    
//    public func deserialize(json: JSON) -> UIColor {
//        switch (json) {
//        case .Str(let s):
//            return UIColor.colorWithHexString(s)
//    default:
//            fatalError("Type error deserializing")
//        }
//    }
}
//public class NSURLSerializer : JSONSerializer {
//    public func deserialize(json: JSON) -> NSURL {
//        switch (json) {
//        case .Str(let s):
//            return NSURL(string: s)!
//        default:
//            fatalError("Type error deserializing")
//        }
//    }
//}
// Date comes in the following format: 2015-06-17T11:53:00-04:00
public class NSDateSerializer : JSONSerializer {
    var dateFormatter: DateFormatter
    
    fileprivate func convertFormat(_ format: String) -> String? {
        func symbolForToken(_ token: String) -> String {
            switch token {
            case "%a": // Weekday as locale’s abbreviated name.
                return "EEE"
            case "%A": // Weekday as locale’s full name.
                return "EEEE"
            case "%w": // Weekday as a decimal number, where 0 is Sunday and 6 is Saturday. 0, 1, ..., 6
                return "ccccc"
            case "%d": // Day of the month as a zero-padded decimal number. 01, 02, ..., 31
                return "dd"
            case "%b": // Month as locale’s abbreviated name.
                return "MMM"
            case "%B": // Month as locale’s full name.
                return "MMMM"
            case "%m": // Month as a zero-padded decimal number. 01, 02, ..., 12
                return "MM"
            case "%y": // Year without century as a zero-padded decimal number. 00, 01, ..., 99
                return "yy"
            case "%Y": // Year with century as a decimal number. 1970, 1988, 2001, 2013
                return "yyyy"
            case "%H": // Hour (24-hour clock) as a zero-padded decimal number. 00, 01, ..., 23
                return "HH"
            case "%I": // Hour (12-hour clock) as a zero-padded decimal number. 01, 02, ..., 12
                return "hh"
            case "%p": // Locale’s equivalent of either AM or PM.
                return "a"
            case "%M": // Minute as a zero-padded decimal number. 00, 01, ..., 59
                return "mm"
            case "%S": // Second as a zero-padded decimal number. 00, 01, ..., 59
                return "ss"
            case "%f": // Microsecond as a decimal number, zero-padded on the left. 000000, 000001, ..., 999999
                return "SSSSSS"
            case "%z": // UTC offset in the form +HHMM or -HHMM (empty string if the the object is naive). (empty), +0000, -0400, +1030
                return "Z"
            case "%Z": // Time zone name (empty string if the object is naive). (empty), UTC, EST, CST
                return "z"
            case "%j": // Day of the year as a zero-padded decimal number. 001, 002, ..., 366
                return "DDD"
            case "%U": // Week number of the year (Sunday as the first day of the week) as a zero padded decimal number. All days in a new year preceding the first Sunday are considered to be in week 0. 00, 01, ..., 53 (6)
                return "ww"
            case "%W": // Week number of the year (Monday as the first day of the week) as a decimal number. All days in a new year preceding the first Monday are considered to be in week 0. 00, 01, ..., 53 (6)
                return "ww" // one of these can't be right
            case "%c": // Locale’s appropriate date and time representation.
                return "" // unsupported
            case "%x": // Locale’s appropriate date representation.
                return "" // unsupported
            case "%X": // Locale’s appropriate time representation.
                return "" // unsupported
            case "%%": // A literal '%' character.
                return "%"
            default:
                return ""
            }
        }
        var newFormat = ""
        var inQuotedText = false
        var i = format.startIndex
        while i < format.endIndex {
            if format[i] == "%" {
                if format.index(after: i) >= format.endIndex {
                    return nil
                }
                i = format.index(after: i)
                let token = "%\(format[i])"
                if inQuotedText {
                    newFormat += "'"
                    inQuotedText = false
                }
                newFormat += symbolForToken(token)
            } else {
                if "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.contains(format[i]) {
                    if !inQuotedText {
                        newFormat += "'"
                        inQuotedText = true
                    }
                } else if format[i] == "'" {
                    newFormat += "'"
                }
                newFormat += String(format[i])
            }
            i = format.index(after: i)
        }
        if inQuotedText {
            newFormat += "'"
        }
        return newFormat
    }
    
    
    init(_ dateFormat: String) {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
        self.dateFormatter.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale!
        dateFormatter.dateFormat = self.convertFormat(dateFormat)
    }
    open func serialize(_ value: Date) -> JSON {
        return .str(self.dateFormatter.string(from: value))
    }
    
    open func deserialize(_ json: JSON) -> Date {
        switch json {
        case .str(let s):
            return self.dateFormatter.date(from: s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}

//public class DeleteResultSerializer : JSONSerializer {
//    init(){}
//    public func deserialize(json: JSON) -> Bool {
//        switch json {
//        case .Null:
//            return true
//        default:
//            fatalError("Type error deserializing")
//        }
//    }
//}
//
//// MARK: Model Serializers
//extension User {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> User {
//            switch json {
//            case .Dictionary(let dict):
//                let id = StringSerializer().deserialize(dict["id"])
//                let username = StringSerializer().deserialize(dict["username"] ?? .Null)
//                let name = StringSerializer().deserialize(dict["name"])
//                let firstName = StringSerializer().deserialize(dict["first_name"])
//                let lastName = StringSerializer().deserialize(dict["last_name"])
//                let downloads = UInt32Serializer().deserialize(dict["downloads"])
//                let profilePhoto = ProfilePhotoURL.Serializer().deserialize(dict["profile_image"])
//                let portfolioURL = NSURLSerializer().deserialize(dict["portfolio_url"])
//                let bio = StringSerializer().deserialize(dict["bio"])
//                let uploadsRemaining = UInt32Serializer().deserialize(dict["uploads_remaining"])
//                let instagramUsername = StringSerializer().deserialize(dict["instagram_username"])
//                let location = StringSerializer().deserialize(dict["location"])
//                let email = StringSerializer().deserialize(dict["email"])
//                return User(id: id, username: username, name: name, firstName: firstName, lastName: lastName, downloads: downloads, profilePhoto: profilePhoto, portfolioURL: portfolioURL, bio: bio, uploadsRemaining: uploadsRemaining, instagramUsername: instagramUsername, location: location, email: email)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//        public func deserialize(json: JSON?) -> User? {
//            if let j = json {
//                return deserialize(j)
//            }
//            return nil
//        }
//    }
//}
//extension ProfilePhotoURL {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> ProfilePhotoURL {
//            switch json {
//            case .Dictionary(let dict):
//                let large = NSURLSerializer().deserialize(dict["large"] ?? .Null)
//                let medium = NSURLSerializer().deserialize(dict["medium"] ?? .Null)
//                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
//                let custom = NSURLSerializer().deserialize(dict["custom"])
//                return ProfilePhotoURL(large: large, medium: medium, small: small, custom: custom)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension CollectionsResult {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> CollectionsResult {
//            switch json {
//            case .Array:
//                let collections = ArraySerializer(Collection.Serializer()).deserialize(json)
//                return CollectionsResult(collections: collections)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Collection {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Collection {
//            switch json {
//            case .Dictionary(let dict):
//                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
//                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
//                let curated = BoolSerializer().deserialize(dict["curated"] ?? .Null)
//                let coverPhoto = Photo.Serializer().deserialize(dict["cover_photo"] ?? .Null)
//                let publishedAt = NSDateSerializer().deserialize(dict["published_at"] ?? .Null)
//                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
//                return Collection(id: id, title: title, curated: curated, coverPhoto: coverPhoto, publishedAt: publishedAt, user: user)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension PhotoCollectionResult {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> PhotoCollectionResult {
//            switch json {
//            case .Dictionary(let dict):
//                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .Null)
//                let collection = Collection.Serializer().deserialize(dict["collection"] ?? .Null)
//                return PhotoCollectionResult(photo: photo, collection: collection)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension PhotoUserResult {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> PhotoUserResult {
//            switch json {
//            case .Dictionary(let dict):
//                let photo = Photo.Serializer().deserialize(dict["photo"] ?? .Null)
//                let user = User.Serializer().deserialize(dict["user"] ?? .Null)
//                return PhotoUserResult(photo: photo, user: user)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Photo {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Photo {
//            switch json {
//            case .Dictionary(let dict):
//                let id = StringSerializer().deserialize(dict["id"] ?? .Null)
//                let width = UInt32Serializer().deserialize(dict["width"])
//                let height = UInt32Serializer().deserialize(dict["height"])
//                let color = UIColorSerializer().deserialize(dict["color"])
//                let user = User.Serializer().deserialize(dict["user"])
//                let url = PhotoURL.Serializer().deserialize(dict["urls"] ?? .Null)
//                let categories = ArraySerializer(Category.Serializer()).deserialize(dict["categories"])
//                let exif = Exif.Serializer().deserialize(dict["exif"])
//                let downloads = UInt32Serializer().deserialize(dict["downloads"])
//                let likes = UInt32Serializer().deserialize(dict["likes"])
//                let location = Location.Serializer().deserialize(dict["location"])
//                return Photo(id: id, width: width, height: height, color: color, user: user, url: url, categories: categories, exif: exif, downloads: downloads, likes: likes, location: location)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension PhotosResult {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> PhotosResult {
//            switch json {
//            case .Array:
//                let photos = ArraySerializer(Photo.Serializer()).deserialize(json)
//                return PhotosResult(photos: photos)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension PhotoURL {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> PhotoURL {
//            switch json {
//            case .Dictionary(let dict):
//                let full = NSURLSerializer().deserialize(dict["full"] ?? .Null)
//                let regular = NSURLSerializer().deserialize(dict["regular"] ?? .Null)
//                let small = NSURLSerializer().deserialize(dict["small"] ?? .Null)
//                let thumb = NSURLSerializer().deserialize(dict["thumb"] ?? .Null)
//                let custom = NSURLSerializer().deserialize(dict["custom"])
//                return PhotoURL(full: full, regular: regular, small: small, thumb: thumb, custom: custom)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Exif {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Exif {
//            switch json {
//            case .Dictionary(let dict):
//                let make = StringSerializer().deserialize(dict["make"])
//                let model = StringSerializer().deserialize(dict["model"])
//                let exposureTime = DoubleSerializer().deserialize(dict["exposure_time"])
//                let aperture = DoubleSerializer().deserialize(dict["aperture"])
//                let focalLength = UInt32Serializer().deserialize(dict["focal_length"])
//                let iso = UInt32Serializer().deserialize(dict["iso"])
//                return Exif(make: make, model: model, exposureTime: exposureTime, aperture: aperture, focalLength: focalLength, iso: iso)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Location {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Location {
//            switch json {
//            case .Dictionary(let dict):
//                let position = Position.Serializer().deserialize(dict["position"] ?? .Null)
//                let city = StringSerializer().deserialize(dict["city"] ?? .Null)
//                let country = StringSerializer().deserialize(dict["country"] ?? .Null)
//                return Location(city: city, country: country, position: position)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Position {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Position {
//            switch json {
//            case .Dictionary(let dict):
//                let latitude = DoubleSerializer().deserialize(dict["latitude"] ?? .Null)
//                let longitude = DoubleSerializer().deserialize(dict["longitude"] ?? .Null)
//                return Position(latitude: latitude, longitude: longitude)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension CategoriesResult {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> CategoriesResult {
//            switch json {
//            case .Array:
//                let categories = ArraySerializer(Category.Serializer()).deserialize(json)
//                return CategoriesResult(categories: categories)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Category {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Category {
//            switch json {
//            case .Dictionary(let dict):
//                let id = UInt32Serializer().deserialize(dict["id"] ?? .Null)
//                let title = StringSerializer().deserialize(dict["title"] ?? .Null)
//                let photoCount = UInt32Serializer().deserialize(dict["photo_count"] ?? .Null)
//                return Category(id: id, title: title, photoCount: photoCount)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}
//extension Stats {
//    public class Serializer : JSONSerializer {
//        public init() {}
//        public func deserialize(json: JSON) -> Stats {
//            switch json {
//            case .Dictionary(let dict):
//                let photoDownloads = UInt32Serializer().deserialize(dict["photo_downloads"] ?? .Null)
//                let batchDownloads = UInt32Serializer().deserialize(dict["batch_downloads"] ?? .Null)
//                return Stats(photoDownloads: photoDownloads, batchDownloads: batchDownloads)
//            default:
//                fatalError("error deserializing")
//            }
//        }
//    }
//}

