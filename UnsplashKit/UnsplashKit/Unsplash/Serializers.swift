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
open class ArraySerializer<T : JSONSerializer> : JSONSerializer {
    
    var elementSerializer : T
    
    init(_ elementSerializer: T) {
        self.elementSerializer = elementSerializer
    }
    
    open func serialize(_ arr: Array<T.ValueType>) -> JSON {
        return .array(arr.map { self.elementSerializer.serialize($0) })
    }
    
    public func deserialize(_ json : JSON) -> Array<T.ValueType> {
        switch json {
        case .array(let arr):
            return arr.map { self.elementSerializer.deserialize($0) }
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

open class NSDateSerializer: JSONSerializer {
    
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
        self.dateFormatter.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale?
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

struct Serialization {
    static var _StringSerializer = StringSerializer()
    static var _BoolSerializer = BoolSerializer()
    static var _UInt64Serializer = UInt64Serializer()
    static var _UInt32Serializer = UInt32Serializer()
    static var _Int64Serializer = Int64Serializer()
    static var _Int32Serializer = Int32Serializer()
    
    static var _VoidSerializer = VoidSerializer()
    static var _NSDataSerializer = NSDataSerializer()
    static var _DoubleSerializer = DoubleSerializer()
    
    static func getFields(_ json: JSON) -> [String: JSON] {
        switch json {
        case .dictionary(let dict):
            return dict
        default:
            fatalError("Type error")
        }
    }
    
    static func getTag(_ d: [String: JSON]) -> String {
        return _StringSerializer.deserialize(d[".tag"]!)
    }
    
}


// Color comes in the following format: #000000
open class UIColorSerializer : JSONSerializer {
    open func serialize(_ value: UIColor) -> JSON {
        return .number(NSNumber())
    }
    
    public func deserialize(_ json: JSON) -> UIColor {
        switch (json) {
        case .str(let s):
            return UIColor.colorWithHexString(s)
        default:
            fatalError("Type error deserializing")
        }
    }
}
public class URLSerializer : JSONSerializer {
    public func serialize(_ value: URL) -> JSON {
        return .str(value.path)
    }
    
    public func deserialize(_ json: JSON) -> URL {
        switch (json) {
        case .str(let s):
            return URL(string: s)!
        default:
            fatalError("Type error deserializing")
        }
    }
}

public class DeleteResultSerializer : JSONSerializer {
    
    public init() { }
    open func serialize(_ value: Bool) -> JSON {
        return .number(NSNumber(value: value as Bool))
    }
    
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
        public func serialize(_ value: User) -> JSON {
            let output = [
                "id": Serialization._StringSerializer.serialize(value.id)
            ]
            
            return .dictionary(output)
        }
        
        
        public func deserialize(_ json: JSON) -> User {
            switch json {
            case .dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"]!)
                let updatedAt = StringSerializer().deserialize(dict["updatedAt"]!)
                let username = StringSerializer().deserialize(dict["username"] ?? .null)
                let name = StringSerializer().deserialize(dict["name"]!)
                let firstName = StringSerializer().deserialize(dict["first_name"]!)
                let lastName = StringSerializer().deserialize(dict["last_name"] ?? .null)
                
                let twitterUsername = StringSerializer().deserialize(dict["twitterUsername"]!)
                
                let totalLikes = Int32Serializer().deserialize(dict["totalLikes"]!)
                let totalPhotos = Int32Serializer().deserialize(dict["totalPhotos"]!)
                
                let totalCollections = Int32Serializer().deserialize(dict["totalCollections"]!)

                let profileImage = ProfilePhotoURL.Serializer().deserialize(dict["profile_image"]!)

                let bio = StringSerializer().deserialize(dict["bio"]!)

                let instagramUsername = StringSerializer().deserialize(dict["instagram_username"]!)
                let location = StringSerializer().deserialize(dict["location"]!)
                
                
                let links = Links.Serializer().deserialize(dict["links"]!)

                return User(id: id, updatedAt: updatedAt, username: username, name: name, firstName: firstName, lastName: lastName, twitterUsername: twitterUsername, instagramUsername: instagramUsername, portfolioUrl: nil, bio: bio, location: location, totalLikes: Int(totalLikes), totalPhotos: Int(totalPhotos), totalCollections: Int(totalCollections), profileImage: profileImage, links: links)
            default:
                fatalError("error deserializing")
            }
        }
        
    }
}

extension Links {
    public class Serializer : JSONSerializer {

        public func serialize(_ value : Links) -> JSON {
            let output = [
                "large": URLSerializer().serialize(value.html)
            ]
            
            return .dictionary(output)
            
            
        }
        
        
        public init() {}
        
        public func deserialize(_ json : JSON) -> Links {
            
            switch json {
            case .dictionary(let dict):
                
                let user = URLSerializer().deserialize(dict["self"]!)
                let html = URLSerializer().deserialize(dict["html"]!)
                let download = URLSerializer().deserialize(dict["download"]!)
                let downloadLocation = URLSerializer().deserialize(dict["downloadLocation"]!)
                return Links(user: user, html: html, download: download, downloadLocation: downloadLocation)
                
            default:
                fatalError("error deserializing")
            }
            
        }
        
        
    }
    
}

extension ProfilePhotoURL {
    public class Serializer : JSONSerializer {
        public func serialize(_ value: ProfilePhotoURL) -> JSON {
            let output = [
                "large": URLSerializer().serialize(value.large)
            ]
            
            return .dictionary(output)
        }
        
        public init() {}
        public func deserialize(_ json: JSON) -> ProfilePhotoURL {
            switch json {
            case .dictionary(let dict):
                let large = URLSerializer().deserialize(dict["large"] ?? .null)
                let medium = URLSerializer().deserialize(dict["medium"] ?? .null)
                let small = URLSerializer().deserialize(dict["small"] ?? .null)

                return ProfilePhotoURL(small: small, medium: medium, large: large)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension CollectionsResult {
    public class Serializer : JSONSerializer {
        public func serialize(_ value: CollectionsResult) -> JSON {
            let output = [
                "collections": ArraySerializer(Collection.Serializer()).serialize(value.collections)
            ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: Collection) -> JSON {
            let output = [
                "id": Serialization._UInt32Serializer.serialize(value.id)
            ]
            
            return .dictionary(output)
        }
        
        public init() {}
        public func deserialize(_ json: JSON) -> Collection {
            switch json {
            case .dictionary(let dict):
                let id = UInt32Serializer().deserialize(dict["id"] ?? .null)
                let title = StringSerializer().deserialize(dict["title"] ?? .null)
                let curated = BoolSerializer().deserialize(dict["curated"] ?? .null)
                let coverPhoto = Photo.Serializer().deserialize(dict["cover_photo"] ?? .null)
                let publishedAt = NSDateSerializer("%Y-%m-%dT%H:%M:%SZ").deserialize(dict["published_at"] ?? .null)
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
        public func serialize(_ value: PhotoCollectionResult) -> JSON {
            let output = [
                "photo": Photo.Serializer().serialize(value.photo)
            ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: PhotoUserResult) -> JSON {
            let output = [
                "photo": Photo.Serializer().serialize(value.photo)
            ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: Photo) -> JSON {
            let output = [
                "id": Serialization._StringSerializer.serialize(value.id)
            ]
            
            return .dictionary(output)
        }
        
        public init() {}
        public func deserialize(_ json: JSON) -> Photo {
            switch json {
            case .dictionary(let dict):
                let id = StringSerializer().deserialize(dict["id"] ?? .null)
                let createdAt = StringSerializer().deserialize(dict["createdAt"] ?? .null)
                let updatedAt = StringSerializer().deserialize(dict["updatedAt"] ?? .null)
                
                let width = UInt32Serializer().deserialize(dict["width"]!)
                let height = UInt32Serializer().deserialize(dict["height"]!)
                let color = UIColorSerializer().deserialize(dict["color"]!)
                let user = User.Serializer().deserialize(dict["user"] ?? .null)
                let url = PhotoURL.Serializer().deserialize(dict["urls"] ?? .null)
                let categories = ArraySerializer(Category.Serializer()).deserialize(dict["categories"]!)
                let exif = Exif.Serializer().deserialize(dict["exif"]!)

                let downloads = UInt32Serializer().deserialize(dict["downloads"] ?? .number(0))
                let likes = UInt32Serializer().deserialize(dict["likes"]!)

                let likedByUser = BoolSerializer().deserialize(dict["likedByUser"]!)
                
                return Photo(id: id, createdAt: createdAt, updatedAt: updatedAt, width: Int(width), height: Int(height), color: color, likes: Int(likes), likedByUser: likedByUser, description: <#Any?#>, sponsored: <#Bool#>, user: user, currentUserCollections: <#[Any]#>, urls: url, categories: categories, links: likes)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension PhotosResult {
    public class Serializer : JSONSerializer {
        public func serialize(_ value: PhotosResult) -> JSON {
            let output = [ "photos": ArraySerializer(Photo.Serializer()).serialize(value.photos) ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: PhotoURL) -> JSON {
            let output = [
                "full": URLSerializer().serialize(value.full),

            ]
            
            return .dictionary(output)
        }
        
        public init() {}
        public func deserialize(_ json: JSON) -> PhotoURL {
            switch json {
            case .dictionary(let dict):
                let raw = URLSerializer().deserialize(dict["raw"] ?? .null)
                let full = URLSerializer().deserialize(dict["full"] ?? .null)
                let regular = URLSerializer().deserialize(dict["regular"] ?? .null)
                let small = URLSerializer().deserialize(dict["small"] ?? .null)
                let thumb = URLSerializer().deserialize(dict["thumb"] ?? .null)

                return PhotoURL(raw: raw, full: full, regular: regular, small: small, thumb: thumb)
            default:
                fatalError("error deserializing")
            }
        }
    }
}

extension Exif {
    public class Serializer : JSONSerializer {
        public func serialize(_ value : Exif) -> JSON {
            
            let output = [
                "make":Serialization._StringSerializer.serialize(value.make!)
                
                
            ]
            
            return .dictionary(output)
            
        }
        
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
        public func serialize(_ value: Location) -> JSON {
            let output = [
                "position": Position.Serializer().serialize(value.positon!),
                "city": Serialization._StringSerializer.serialize(value.city!),
                "country": Serialization._StringSerializer.serialize(value.country!)
            ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: Position) -> JSON {
            let output = [
                "latitude": Serialization._DoubleSerializer.serialize(value.latitude),
                "longitude": Serialization._DoubleSerializer.serialize(value.longitude)
            ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: CategoriesResult) -> JSON {
            let output = ["categories": ArraySerializer(Category.Serializer()).serialize(value.categories)]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value : Category) -> JSON {
            let output = [
                "id": Serialization._UInt32Serializer.serialize(value.id),
                "title": Serialization._StringSerializer.serialize(value.title),
                "photo_count": Serialization._UInt32Serializer.serialize(value.photoCount)
                ]
            
            return .dictionary(output)
        }
        
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
        public func serialize(_ value: Stats) -> JSON {
            let output = [
            "photo_downloads":Serialization._UInt32Serializer.serialize(value.photoDownloads),
            "batch_downloads": Serialization._UInt32Serializer.serialize(value.batchDownloads)]
            
            return .dictionary(output)
        }
        
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
