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
    public func deserialize(_ json: JSON) -> NSURL {
        switch (json) {
        case .str(let s):
            return NSURL(string: s)!
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
                let id = StringSerializer().deserialize(dict["id"])
                let username = StringSerializer().deserialize(dict["username"] ?? .null)
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









