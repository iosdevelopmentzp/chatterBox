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
        .library(name: "DependencyInjector", targets: ["DependencyInjector"]),
        .library(name: "MainAssembly", targets: ["MainAssembly"]),
        
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
            "Scenes_Chat",
            "DependencyInjector"
        ]),
        
        .target(name: "Core"),
        
        .target(name: "CoreDataPersistents", dependencies: ["DependencyInjector"]),
        
        .target(name: "DependencyInjector"),
        
        .target(name: "MainAssembly", dependencies: [
            "CoreDataPersistents",
            "DependencyInjector",
            "CoreStorageService",
            "UseCases",
            "StorageServices"
        ]),
        
        // services
        
        .target(name: "CoreStorageService", dependencies: ["DependencyInjector"]),
        
        .target(name: "StorageServices", dependencies: [
            "Core",
            "DependencyInjector",
            "CoreStorageService"
        ]),
        
        .target(name: "Scenes_Chat", dependencies: [
            "Core",
            "UseCases"
        ]),
        
        .target(name: "UseCases", dependencies: [
            "StorageServices",
            "Core",
            "DependencyInjector"
        ]),
        
        .testTarget(name: "ChatterBoxEngineTests", dependencies: []),
    ]
)
