import Turnstile
import PerfectHTTP

public class TurnstilePerfect {
    public var filter: (HTTPRequestFilter, HTTPFilterPriority)
    
    private let turnstile: Turnstile
    
    public init(sessionManager: SessionManager = MemorySessionManager(), realm: Realm = MemoryRealm()) {
        turnstile = Turnstile(sessionManager: MemorySessionManager(), realm: MemoryRealm())
        filter = (TurnstileFilter(turnstile: turnstile), HTTPFilterPriority.high)
    }
}

import Foundation
let configuration = URLSessionConfiguration()
let session = URLSession(configuration: configuration)
