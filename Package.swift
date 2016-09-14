import PackageDescription

let package = Package(
    name: "TurnstilePerfect",
  dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTP.git", majorVersion: 2),
    .Package(url: "https://github.com/stormpath/Turnstile.git", majorVersion: 1)
    ]
)
