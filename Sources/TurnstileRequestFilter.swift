//
//  TurnstileRequestFilter.swift
//  TurnstilePerfect
//
//  Created by Edward Jiang on 8/23/16.
//
//

import PerfectHTTP
import Turnstile

public class TurnstileRequestFilter: HTTPRequestFilter {
    private let turnstile: Turnstile
    
    init(turnstile: Turnstile) {
        self.turnstile = turnstile
    }
    
    public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        // Initialize session
        // Token/API Key Auth
        //
        request.user = Subject(turnstile: turnstile, sessionID: request.getCookie(name: "TurnstileSession"))
        
        print("Cookie: \(request.getCookie(name: "TurnstileSession"))")
        
        if let apiKeys = request.auth?.basic {
            try? request.user.login(credentials: apiKeys)
        } else if let token = request.auth?.bearer {
            try? request.user.login(credentials: token)
        }
        
        callback(HTTPRequestFilterResult.continue(request, response))
    }
}
