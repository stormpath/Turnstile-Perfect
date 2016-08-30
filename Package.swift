import PackageDescription

let package = Package(
    name: "TurnstilePerfect",
  dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", versions: Version(0,0,0)..<Version(10,0,0)),
    .Package(url: "https://github.com/stormpath/Turnstile.git", majorVersion: 0, minor: 3)
    ]
)
