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
        .library(name: "ImageCacheKit", targets: ["ImageCacheKit"]),
        
        // use cases
        
        .library(name: "UseCases", targets: ["UseCases"]),
        
        // scenes
        
        .library(name: "Scenes_Chat", targets: ["Scenes_Chat"]),
        .library(name: "Scenes_ImagePicker", targets: ["Scenes_ImagePicker"]),
        
        // UI
        
        .library(name: "UIComponentsKit", targets: ["UIComponentsKit"])
    ],
    targets: [
        .target(name: "Coordinators", dependencies: [
            "Scenes_Chat",
            "Scenes_ImagePicker",
            "DependencyInjector",
            "UIComponentsKit"
        ]),
        
        .target(name: "Core"),
        
        .target(name: "CoreDataPersistents", dependencies: ["DependencyInjector"]),
        
        .target(name: "DependencyInjector"),
        
        .target(name: "MainAssembly", dependencies: [
            "CoreDataPersistents",
            "DependencyInjector",
            "CoreStorageService",
            "UseCases",
            "StorageServices",
            "ImageCacheKit"
        ]),
        
        // services
        
        .target(name: "CoreStorageService", dependencies: ["DependencyInjector"]),
        
        .target(name: "StorageServices", dependencies: [
            "Core",
            "DependencyInjector",
            "CoreStorageService"
        ]),
        
        .target(name: "ImageCacheKit", dependencies: ["DependencyInjector"]),
        
        // use cases
        
        .target(name: "UseCases", dependencies: [
            "StorageServices",
            "Core",
            "DependencyInjector"
        ]),
        
        // scenes
    
        .target(name: "Scenes_Chat", dependencies: [
            "Core",
            "UseCases",
            "ImageCacheKit"
        ]),
        
        .target(name: "Scenes_ImagePicker", dependencies: [
            "ImageCacheKit",
            "UIComponentsKit"
        ]),
        
        // UI
        
        .target(name: "UIComponentsKit"),
    
        .testTarget(name: "ChatterBoxEngineTests", dependencies: []),
    ]
)
