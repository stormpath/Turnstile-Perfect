# Turnstile-Perfect
[![codebeat badge](https://codebeat.co/badges/0d334c15-4c66-4577-8fe0-6dc5934b194c)](https://codebeat.co/projects/github-com-stormpath-turnstile-perfect) [![Slack Status](https://talkstormpath.shipit.xyz/badge.svg)](https://talkstormpath.shipit.xyz)

This is the [Turnstile](https://github.com/stormpath/Turnstile) integration with [Perfect](https://github.com/PerfectlySoft/Perfect), which integrates authentication into a popular Swift web framework. 

With Turnstile-Perfect, you can add username/password, API Key, Token, and Facebook / Google authentication into your Perfect application with ease. 

# Usage

To install Turnstile in your Perfect application, add this line to your `Package.swift` dependencies:

```Swift
.Package(url: "https://github.com/stormpath/Turnstile-Perfect.git", majorVersion:1)
```

Then, in your Perfect application, `import Turnstile`, initialize the TurnstilePerfect object, and add Turnstile to your Perfect application's request and response filters:

```Swift
// The Perfect Server
let server = HTTPServer()

// The Turnstile instance
let turnstile = TurnstilePerfect()

server.setRequestFilters([turnstile.requestFilter])
server.setResponseFilters([turnstile.responseFilter])
```

By default, Turnstile-Perfect uses Turnstile's `MemorySessionManager` and `MemoryWebRealm` to store user accounts and sessions in memory. This is great for development purposes, but your accounts will disappear when the server is shut off. To persist your user accounts to a database, you'll need to build your own Realm by [reading the Turnstile documentation](https://github.com/stormpath/Turnstile#realm).

The `WebMemoryRealm` supports Username/Password, Facebook, and Google authentication. 

## Authenticating a User

Turnstile extends Perfect by adding a `user` property to every HTTPRequest. This is a Turnstile `Subject`, which represents the current operating user, and what we know about them. For a username/password combination, we'll need to login a user. We can collect the user info from the request, put them in a `UsernamePassword` object, and give it to Turnstile to authenticate.

```Swift
let credentials = UsernamePassword(username: username, password: password)

do {
    try request.user.login(credentials: credentials, persist: true)
    // If this call succeeds without throwing an error, the user is now logged in. 
} catch let error as TurnstileError {
    // TurnstileErrors have error.description string which is safe to display to the user.
}
```

When the user is authenticated, you can query for things like:

```Swift
// True if the user is authenticated
request.user.authenticated 

// The unique ID of the account in the database
request.user.authDetails?.account.uniqueID 

// A string with the session ID, if persist is true
request.user.authDetails?.sessionID 

// This would be UsernamePassword.self on the first request, and
// Session.self on subsequent requests. 
request.user.authDetails?.credentialType 
```

## Registering a User

As a convenience, you can register users using Turnstile and the MemoryWebRealm. This looks the same as logging in, except for:

```Swift
try request.user.register(credentials: credentials)
```

Registering a user does not automatically log them in, so you'll need to call `login` afterwards as well. 

## Authenticating with Facebook or Google

The Facebook and Google Login flows look like the following:

1. Your web application redirects the user to the Facebook / Google login page, and saves a "state" to prevent a malicious attacker from hijacking the login session. 
2. The user logs in.
3. Facebook / Google redirects the user back to your application. 
4. The application validates the Facebook / Google token as well as the state, and logs the user in. 

### Create a Facebook Application

To get started, you first need to [register an application](https://developers.facebook.com/?advanced_app_create=true) with Facebook. After registering your app, go into your app dashboard's settings page. Add the Facebook Login product, and save the changes. 

In the `Valid OAuth redirect URIs` box, type in a URL you'll use for step 3 in the OAuth process. (eg, `http://localhost:8080/login/facebook/consumer`)

### Create a Google Application

To get started, you first need to [register an application](https://console.developers.google.com/project) with Google. Click "Enable and Manage APIs", and then the [credentials tab](https://console.developers.google.com/apis/credentials). Create an OAuth Client ID for "Web".

Add a URL you'll use for step 3 in the OAuth process to the `Authorized redirect URIs` list. (eg, `http://localhost:8080/login/google/consumer`)

### Initiating the Login Redirect

To use Facebook/Google login, `import TurnstileWeb`. TurnstileWeb has `Facebook` and `Google` objects, which will allow a you to set up your configured application and log users in. To initialize them, use the client ID and secret (sometimes called App ID) from your Facebook or Google developer console:

```Swift
let facebook = Facebook(clientID: "clientID", clientSecret: "clientSecret")
let google = Google(clientID: "clientID", clientSecret: "clientSecret")
```

Then, we'll generate a "state", save it with a cookie, and redirect the user:

```Swift
routes.add(method: .get, uri: "/login/facebook") { request, response in
    let state = URandom().secureToken // This is using the TurnstileCrypto random token generator. 
    let redirectURL = facebook.getLoginLink(redirectURL: "http://localhost:8181/login/facebook/consumer", state: state)

    response.status = .found
    response.setHeader(HTTPResponseHeader.Name.location, value: redirectURL.absoluteString)
    response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: HTTPCookie.Expiration.relativeSeconds(3600), path: "/", secure: nil, httpOnly: true))
    response.completed()
}
```

### Consuming the Login Response

Once the user is redirected back to your application, you can now verify that they've properly authenticated using the `state` from the earlier step, and the full URL that the user has been redirected to. If successful, it will return a `FacebookAccount` or `GoogleAccount`. These implement the `Credentials` protocol, so then can be passed back into your application's Realm for further validation.

```Swift
routes.add(method: .get, uri: "/login/facebook/consumer") { request, response in
    // Check that the state matches the cookie. 
    guard let state = request.cookies.filter({$0.0 == "OAuthState"}).first?.1 else {
        // Render error page
        return
    }
    // Expire the "state" token. 
    response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: HTTPCookie.Expiration.absoluteSeconds(0), path: "/", secure: nil, httpOnly: true))

    var uri = "http://localhost:8181" + request.uri

    do {
        let credentials = try facebook.authenticate(authorizationCodeCallbackURL: uri, state: state) as! FacebookAccount

        // Use the credentials to login. 
        try request.user.login(credentials: credentials, persist: true)

        response.status = .found
        response.addHeader(.location, value: "/")
        response.completed()
    } catch let error {
        // Render error page
    }
}
```

Congrats! You've gotten your first application working with Turnstile! To do more advanced things, we recommend digging into the code, or reading the [Turnstile](https://github.com/stormpath/Turnstile) documentation for more information. 

# Contributing

We're always open to contributions! Since this project is fairly early stage, please join the [Stormpath slack channel](https://talkstormpath.shipit.xyz) to discuss how you can contribute!

# Stormpath

Turnstile is built by [Stormpath](https://stormpath.com), an API service for authentication, authorization, and user management. If you're building a website, API, or app, and need to build authentication and user managmeent, consider using Stormpath for your needs. We're always happy to help!