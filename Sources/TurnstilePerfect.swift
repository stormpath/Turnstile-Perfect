import Turnstile
import PerfectHTTP

public class TurnstilePerfect {
    public var requestFilter: (HTTPRequestFilter, HTTPFilterPriority)
    public var responseFilter: (HTTPResponseFilter, HTTPFilterPriority)
    
    private let turnstile: Turnstile
    
    public init(sessionManager: SessionManager = MemorySessionManager(), realm: Realm = MemoryRealm()) {
        turnstile = Turnstile(sessionManager: MemorySessionManager(), realm: MemoryRealm())
        let filter = TurnstileFilter(turnstile: turnstile)
        
        // Not sure how polymorphicism works with tuples, but the compiler was crashing on me
        // So I did this
        requestFilter = (filter, HTTPFilterPriority.high)
        responseFilter = (filter, HTTPFilterPriority.high)
    }
}

import Foundation
let configuration = URLSessionConfiguration()
let session = URLSession(configuration: configuration)
