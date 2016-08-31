//
//  TurnstileRequestFilter.swift
//  TurnstilePerfect
//
//  Created by Edward Jiang on 8/23/16.
//
//

import PerfectHTTP
import Turnstile

public class TurnstileFilter {
    fileprivate let turnstile: Turnstile
    
    init(turnstile: Turnstile) {
        self.turnstile = turnstile
    }
}

extension TurnstileFilter: HTTPRequestFilter {

    public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        // Initialize session
        // Token/API Key Auth
        //
        request.user = Subject(turnstile: turnstile, sessionID: request.getCookie(name: "TurnstileSession"))
        
        if let apiKeys = request.auth?.basic {
            try? request.user.login(credentials: apiKeys)
        } else if let token = request.auth?.bearer {
            try? request.user.login(credentials: token)
        }
        
        callback(HTTPRequestFilterResult.continue(request, response))
    }
}

extension TurnstileFilter: HTTPResponseFilter {

    /// Called once before headers are sent to the client.
    public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        if let sessionID = response.request.user.authDetails?.sessionID {
            response.addCookie(HTTPCookie(name: "TurnstileSession",
                                          value: "\(sessionID)",
                domain: nil,
                expires: .relativeSeconds(60*60*24*365),
                path: "/",
                secure: nil,
                httpOnly: true))
        }
        callback(.continue)
    }
    
    /// Called zero or more times for each bit of body data which is sent to the client.
    public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
}
