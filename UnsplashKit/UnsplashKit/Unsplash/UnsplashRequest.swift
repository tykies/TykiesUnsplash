//
//  UnsplashRequest.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/18.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import Foundation
import Alamofire

public class UnsplashRequest<RType : JSONSerializer> {
    let responseSerializer : RType
    let request : DataRequest
    
    init(client: UnsplashClient, method: HTTPMethod, route: String, auth: Bool, params: [String : AnyObject]?, responseSerializer: RType) {

        self.responseSerializer = responseSerializer
        

        
        let url = "\(client.host)\(route)"
        let headers = client.additionalHeaders(authNeeded: auth)

        self.request = client.manager.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers)
        
        request.resume()
    }
    
    convenience init(client: UnsplashClient, route: String, auth: Bool, params: [String : AnyObject]?, responseSerializer: RType) {

        self.init(client: client, method: .get, route: route, auth: auth, params: params, responseSerializer: responseSerializer)

    }
    
    @discardableResult
    public func response(_ completionHandler: @escaping (RType.ValueType?, CallError?) -> Void) -> Self {
        
        self.request.validate().responseJSON { response in
            
            if (response.result.isFailure) {
                completionHandler(nil, self.handleResponseError(response))
            } else {
                let value = response.result.value!
                completionHandler(self.responseSerializer.deserialize(SerializeUtil.objectToJSON(value as AnyObject)), nil)
//                completionHandler(responseSerializer.deserialize(SerializeUtil.prepareJSONForSerialization(value as! JSON) as! JSON), nil)
            }
        }

        
        return self
    }
    
    func handleResponseError(_ response: DataResponse<Any>) -> CallError {
        let _response = response.response
        let data = response.data
        let error = response.result.error
        let requestId = _response?.allHeaderFields["X-Request-Id"] as? String
        if let code = _response?.statusCode {
            switch code {
            case 500...599:
                var message = ""
                if let d = data {
                    message = utf8Decode(d)
                }
                return .InternalServerError(code, message, requestId)
            case 400:
                var message = ""
                if let d = data {
                    message = utf8Decode(d)
                }
                return .BadInputError(message, requestId)
            case 429:
                return .RateLimitError
            case 403, 404, 409:
                let json = SerializeUtil.parseJSON(data!)
                switch json {
                case .dictionary(let d):
                    return .RouteError(ArraySerializer(StringSerializer()).deserialize(d["errors"]!) , requestId)
                default:
                    fatalError("Failed to parse error type")
                }
            case 200:
                return .OSError(error as? Error)
            default:
                return .HTTPError(code, "An error occurred.", requestId)
            }
        } else {
            var message = ""
            if let d = data {
                message = utf8Decode(d)
            }
            return .HTTPError(nil, message, requestId)
        }
        return .HTTPError(nil, "", "")
    }
}

public enum CallError : CustomStringConvertible {
    case InternalServerError(Int, String?, String?)
    case BadInputError(String?, String?)
    case RateLimitError
    case HTTPError(Int?, String?, String?)
    case RouteError(Array<String>, String?)
    case OSError(Error?)
    
    public var description : String {
        switch self {
        case let .InternalServerError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Internal Server Error \(code)"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .BadInputError(message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "Bad Input"
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case .RateLimitError:
            return "Rate limited"
        case let .HTTPError(code, message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "HTTP Error"
            if let c = code {
                ret += "\(c)"
            }
            if let m = message {
                ret += ": \(m)"
            }
            return ret
        case let .RouteError(message, requestId):
            var ret = ""
            if let r = requestId {
                ret += "[request-id \(r)] "
            }
            ret += "API route error - \(message)"
            return ret
        case let .OSError(err):
            if let e = err {
                return "\(e)"
            }
            return "An unknown system error"
        }
    }
}

func utf8Decode(_ data: Data) -> String {
    return String(data: data, encoding: String.Encoding.utf8)!

}

