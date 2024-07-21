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
        
        .library(name: "CoreStorageService", targets: ["CoreStorageService"]),
        .library(name: "StorageServices", targets: ["StorageServices"]),
        
        // use cases
        
        .library(name: "UseCases", targets: ["UseCases"]),
        
        // scenes
        
        .library(name: "Scenes_Chat", targets: ["Scenes_Chat"])
    ],
    targets: [
        .target(name: "Coordinators", dependencies: [
            "Scenes_Chat"
        ]),
        
        .target(name: "Core"),
        
        .target(name: "CoreDataPersistents"),
        
        .target(name: "CoreStorageService"),
        
        .target(name: "StorageServices", dependencies: ["Core"]),
        
        .target(name: "Scenes_Chat"),
        
        .target(name: "UseCases", dependencies: [
            "StorageServices",
            "Core"
        ]),
        
        .testTarget(name: "ChatterBoxEngineTests", dependencies: []),
    ]
)
