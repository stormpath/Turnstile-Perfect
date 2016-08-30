import Turnstile
import PerfectHTTP

public class TurnstilePerfect {
    public var requestFilter: (HTTPRequestFilter, HTTPFilterPriority) {
        return (TurnstileRequestFilter(turnstile: turnstile), HTTPFilterPriority.high)
    }
    
    private let turnstile: Turnstile
    
    public init(sessionManager: SessionManager = MemorySessionManager(), realm: Realm = MemoryRealm()) {
        turnstile = Turnstile(sessionManager: MemorySessionManager(), realm: MemoryRealm())
    }
}

import Foundation
let configuration = URLSessionConfiguration()
let session = URLSession(configuration: configuration)
