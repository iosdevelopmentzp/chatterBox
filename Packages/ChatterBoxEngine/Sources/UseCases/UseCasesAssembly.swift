//
//  UseCasesAssembly.swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import DependencyInjector

public final class UseCasesAssembly: Assembly {
    public init() {}
    
    public func assemble(resolver: DependencyResolving) {
        resolver.registerDependency(type: UserUseCaseProtocol.self, scope: .transient) { resolver in
            UserUseCase(storage: resolver.resolveDependency())
        }
        
        resolver.registerDependency(type: ChatUseCaseProtocol.self, scope: .transient) { resolver in
            ChatUseCase(storageService: resolver.resolveDependency())
        }
    }
}
