// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatterBoxEngine",
    platforms: [.iOS(.v15)],
    products: [
        // core
        
        .library(name: "Coordinators", targets: ["Coordinators"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreDataPersistents", targets: ["CoreDataPersistents"]),
        
        // services
        
        
        
        // scenes
        
        .library(name: "Scenes_Chat", targets: ["Scenes_Chat"])
    ],
    targets: [
        .target(name: "Coordinators", dependencies: [
            "Scenes_Chat"
        ]),
        
        .target(name: "Core"),
        
        .target(name: "CoreDataPersistents"),
        
        .target(name: "Scenes_Chat"),
        
        .testTarget(name: "ChatterBoxEngineTests", dependencies: []),
    ]
)
