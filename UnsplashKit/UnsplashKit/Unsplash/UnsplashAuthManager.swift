//
//  UnsplashAuthManager.swift
//  UnsplashKit
//
//  Created by susuyan on 2017/11/9.
//  Copyright © 2017年 susuyan. All rights reserved.
//

import UIKit
import WebKit
import Security
import Alamofire

public class UnsplashAuthManager {
    
    private static let host = "unsplash.com"
    
    public static let publicScope = ["public"]
    public static let allScopes = [
        "public",
        "read_user",
        "write_user",
        "read_photos",
        "write_photos",
        "write_likes",
        "read_collections",
        "write_collections"
    ]
    
    private let appId : String
    private let secret : String
    private let redirectURL : URL
    private let scopes : [String]
    
    public static var sharedAuthManager : UnsplashAuthManager!
    
    public init(appId: String, secret: String, scopes: [String]=UnsplashAuthManager.publicScope) {
        self.appId = appId
        self.secret = secret
        self.redirectURL = URL(string: "unsplash-\(self.appId)://token")!
        self.scopes = scopes
    }
    
    public func authorizeFromController(controller: UIViewController, completion:@escaping (UnsplashAccessToken?, NSError?) -> Void) {
        let connectController = UnsplashConnectController(startURL: self.authURL(), dismissOnMatchURL: self.redirectURL)
        connectController.onWillDismiss = { didCancel in
            if (didCancel) {
                completion(nil, Error.errorWithCode(code: .UserCanceledAuth, description: "User canceled authorization"))
                

            }
        }
        connectController.onMatchedURL = { url in
            self.retrieveAccessTokenFromURL(url: url, completion: completion)
        }
        let navigationController = UINavigationController(rootViewController: connectController)
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    private func retrieveAccessTokenFromURL(url: URL, completion: ((UnsplashAccessToken?, NSError?) -> Void)) {
        let (code, error) = extractCodeFromRedirectURL(url: url)
        
        if let e = error {
            completion(nil, e)
            return
        }

        
        Alamofire.request(.POST, accessTokenURL(code!)).validate().responseJSON { response in
            switch response.result {
            case .Success(let value):
                let token = UnsplashAccessToken(appId: self.appId, accessToken: value["access_token"]! as! String)
                Keychain.set(self.appId, value: token.accessToken)
                completion(token, nil)
            case .Failure(_):
                let error = self.extractErrorFromData(response.data!)
                completion(nil, error)
            }
        }
    }
    
    private func authURL() -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = UnsplashAuthManager.host
        components.path = "/oauth/authorize"
        
        components.queryItems = [
            

            URLQueryItem(name: "response_type", value: "code") ,
            URLQueryItem(name: "client_id", value: self.appId),
            URLQueryItem(name: "redirect_uri", value: self.redirectURL.absoluteString),
            URLQueryItem(name: "scope", value: self.scopes.joined(separator: "+")),
        ]
        return components.url!
    }
    
    private func accessTokenURL(_ code: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = UnsplashAuthManager.host
        components.path = "/oauth/token"
        
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: self.appId),
            URLQueryItem(name: "client_secret", value: self.secret),
            URLQueryItem(name: "redirect_uri", value: self.redirectURL.absoluteString),
            URLQueryItem(name: "code", value: code),
        ]
        return components.url!
    }
    
    private func extractCodeFromRedirectURL(url: URL) -> (String?, NSError?) {
        let pairs = url.queryPairs
        if let error = pairs["error"] {
//            let desc = pairs["error_description"]?.stringByReplacingOccurrencesOfString("+", withString: " ").stringByRemovingPercentEncoding
            let desc = pairs["error_description"]?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding
            
            
            return (nil, Error.errorWithCodeString(codeString: error, description: desc))
        } else {
            let code = pairs["code"]!
            return (code, nil)
        }
    }
    
    private func extractErrorFromData(data: Data) -> NSError? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:String]
            return Error.errorWithCodeString(codeString: json!["error"]!, description: json!["error_description"])
        } catch {
            return nil
        }
    }
    
    public func getAccessToken() -> UnsplashAccessToken? {
        if let accessToken = Keychain.get(key: self.appId) {
            return UnsplashAccessToken(appId: self.appId, accessToken: accessToken)
        }
        return nil
    }
    
    public func clearAccessToken() -> Bool {
        return Keychain.clear()
    }
}

class UnsplashConnectController : UIViewController, WKNavigationDelegate {
    var webView : WKWebView!
    
    var onWillDismiss: ((_ didCancel: Bool) -> Void)?
    var onMatchedURL: ((_ url: URL) -> Void)?
    
    var cancelButton: UIBarButtonItem?
    
    let startURL : URL
    let dismissOnMatchURL : URL
    
    init(startURL: URL, dismissOnMatchURL: URL) {
        self.startURL = startURL
        self.dismissOnMatchURL = dismissOnMatchURL
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Link to Unsplash"
        self.webView = WKWebView(frame: self.view.bounds)
        self.view.addSubview(self.webView)
        
        self.webView.navigationDelegate = self
        
        self.view.backgroundColor = UIColor.white
        
        self.cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: Selector(("cancel:")))
        self.navigationItem.rightBarButtonItem = self.cancelButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !webView.canGoBack {
            loadURL(url: startURL)

        }
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            if self.dimissURLMatchesURL(url: url) {
                self.onMatchedURL?(url)
                self.dismiss(animated: true)
                return decisionHandler(.cancel)
            }
        }
        return decisionHandler(.allow)
    }
    
    func loadURL(url: URL) {
        webView.load(URLRequest(url: url))

    }
    
    func dimissURLMatchesURL(url: URL) -> Bool {
        if (url.scheme == self.dismissOnMatchURL.scheme &&
            url.host == self.dismissOnMatchURL.host &&
            url.path == self.dismissOnMatchURL.path) {
            return true
        }
        return false
    }
    
    func showHideBackButton(show: Bool) {
        navigationItem.leftBarButtonItem = show ? UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: Selector(("goBack:"))) : nil
    }
    
    func goBack(sender: AnyObject?) {
        webView.goBack()
    }
    
    func cancel(sender: AnyObject?) {
        dismiss(true, animated: (sender != nil))
    }
    
    func dismiss(animated: Bool) {
        dismiss(false, animated: animated)
    }
    
    func dismiss(_ asCancel: Bool, animated: Bool) {
        webView.stopLoading()
        
        self.onWillDismiss?(asCancel)
        presentingViewController?.dismiss(animated: animated, completion: nil)
    }
}

public class UnsplashAccessToken : CustomStringConvertible {
    public let appId: String
    public let accessToken: String
    // TODO: Keep track of the refresh token.
    // public let refreshToken: String
    
    public init(appId: String, accessToken: String) {
        self.appId = appId
        self.accessToken = accessToken
    }
    
    public var description : String {
        return self.accessToken
    }
}

public struct Error {
    public static let Domain = "com.unsplash.error"
    public enum Code: Int {
        /// The client is not authorized to request an access token using this method.
        case UnauthorizedClient = 1
        
        /// The resource owner or authorization server denied the request.
        case AccessDenied
        
        /// The authorization server does not support obtaining an access token using this method.
        case UnsupportedResponseType
        
        /// The requested scope is invalid, unknown, or malformed.
        case InvalidScope
        
        /// The authorization server encountered an unexpected condition that prevented it from
        /// fulfilling the request.
        case ServerError
        
        /// Client authentication failed due to unknown client, no client authentication included,
        /// or unsupported authentication method.
        case InvalidClient
        
        /// The request is missing a required parameter, includes an unsupported parameter value, or
        /// is otherwise malformed.
        case InvalidRequest
        
        /// The provided authorization grant is invalid, expired, revoked, does not match the
        /// redirection URI used in the authorization request, or was issued to another client.
        case InvalidGrant
        
        /// The authorization server is currently unable to handle the request due to a temporary
        /// overloading or maintenance of the server.
        case TemporarilyUnavailable
        
        // The user canceled the authorization process.
        case UserCanceledAuth
        
        /// Some other error.
        case Unknown
    }
    
    static func errorWithCodeString(codeString: String, description: String?) -> NSError {
        var code : Code
        switch codeString {
        case "unauthorized_client": code = .UnauthorizedClient
        case "access_denied": code = .AccessDenied
        case "unsupported_response_type": code = .UnsupportedResponseType
        case "invalid_scope": code = .InvalidScope
        case "invalid_client": code = .InvalidClient
        case "server_error": code = .ServerError
        case "temporarily_unavailable": code = .TemporarilyUnavailable
        case "invalid_request": code = .InvalidRequest
        default: code = .Unknown
        }
        
        return errorWithCode(code: code, description: description)
    }
    
    static func errorWithCode(code: Code, description: String?) -> NSError {
        var info : [NSObject : AnyObject]?
        if let d = description {
            info = [NSLocalizedDescriptionKey as NSObject : d as AnyObject]
        }
        return NSError(domain: Domain, code: code.rawValue, userInfo: (info as! [String : Any]))
    }
}

class Keychain {
    
    class func queryWithDict(query: [String : AnyObject]) -> CFDictionary {

        let bundleId = Bundle.main.bundleIdentifier ?? ""
        
        var queryDict = query
        
        queryDict[kSecClass as String]       = kSecClassGenericPassword
        queryDict[kSecAttrService as String] = "\(bundleId).unsplash.auth" as AnyObject
        
        return queryDict as CFDictionary
    }
    
    class func set(key: String, value: String) -> Bool {
        if let data = value.data(using: String.Encoding.utf8) {
            return set(key: String, value: data)
        } else {
            return false
        }
    }
    
    class func set(key: String, value: NSData) -> Bool {
        let query = Keychain.queryWithDict(query: [
            (kSecAttrAccount as String): key as AnyObject,
            (  kSecValueData as String): value
            ])
        
        SecItemDelete(query)
        
        return SecItemAdd(query, nil) == noErr
    }
    
    class func getAsData(key: String) -> Data? {
        let query = Keychain.queryWithDict(query: [
            (kSecAttrAccount as String): key as AnyObject,
            ( kSecReturnData as String): kCFBooleanTrue,
            ( kSecMatchLimit as String): kSecMatchLimitOne
            ])
        
        var dataResult : AnyObject?
        let status = withUnsafeMutablePointer(to: &dataResult) { (ptr) in
            SecItemCopyMatching(query, UnsafeMutablePointer(ptr))
        }
        
        if status == noErr {
            return dataResult as? Data
        }
        
        return nil
    }
    
    class func get(key: String) -> String? {
        if let data = getAsData(key: key) {

            return String(data: data, encoding: String.Encoding.utf8)
        } else {
            return nil
        }
    }
    
    class func delete(key: String) -> Bool {
        let query = Keychain.queryWithDict(query: [
            (kSecAttrAccount as String): key as AnyObject
            ])
        
        return SecItemDelete(query) == noErr
    }
    
    class func clear() -> Bool {
        let query = Keychain.queryWithDict(query: [:])
        return SecItemDelete(query) == noErr
    }
}







