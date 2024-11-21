import PackageDescription

let package = Package(
    name: "TestFrameworkIos1",
    products: [
        .library(name: "TestFrameworkIos1", targets: ["TestFrameworkIos1"])
    ],
    targets: [
        .target(
            name: "TestFrameworkIos1",
            path: "TestFrameworkIos1"
        )
    ]
)
