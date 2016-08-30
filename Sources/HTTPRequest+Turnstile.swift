//
//  HTTPRequest+Turnstile.swift
//  TurnstilePerfect
//
//  Created by Edward Jiang on 8/23/16.
//
//

import PerfectHTTP
import Turnstile
import Foundation

public extension HTTPRequest {
    internal(set) public var user: Subject {
        get {
            return scratchPad["TurnstileSubject"] as! Subject
        }
        set {
            scratchPad["TurnstileSubject"] = newValue
        }
    }
}

struct AuthorizationHeader {
    let headerValue: String
    
    init?(value: String?) {
        guard let value = value else { return nil }
        headerValue = value
    }
    
    var basic: APIKey? {
        guard let range = headerValue.range(of: "Basic ") else { return nil }
        let token = headerValue.substring(from: range.upperBound)
        
        guard let data = Data(base64Encoded: token) else { return nil }
        
        
        guard let decodedToken = String(data: data, encoding: .utf8),
            let separatorRange = decodedToken.range(of: ":") else {
                return nil
        }
        
        let apiKeyID = decodedToken.substring(to: separatorRange.lowerBound)
        let apiKeySecret = decodedToken.substring(from: separatorRange.upperBound)
        
        return APIKey(id: apiKeyID, secret: apiKeySecret)
    }
    
    var bearer: AccessToken? {
        guard let range = headerValue.range(of: "Bearer ") else { return nil }
        let token = headerValue.substring(from: range.upperBound)
        return AccessToken(string: token)
    }
}

extension HTTPRequest {
    var auth: AuthorizationHeader? {
        return AuthorizationHeader(value: self.header(.authorization))
    }
}

extension HTTPRequest {
    func getCookie(name: String) -> String? {
        for (cookieName, payload) in self.cookies {
            if name == cookieName {
                return payload
            }
        }
        return nil
    }
}
