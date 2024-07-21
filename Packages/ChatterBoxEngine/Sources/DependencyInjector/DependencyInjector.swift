//
//  DependencyInjector..swift
//
//
//  Created by Dmytro Vorko on 21/07/2024.
//

import Foundation

public enum ResolutionScope {
    case transient
    case singleton
    case weak
}

public protocol DependencyResolving {
    func resolveDependency<T>() -> T
    func registerDependency<T>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving) -> T)
}

extension DependencyResolving {
    func registerDependency<T>(type: T.Type, factory: @escaping (DependencyResolving) -> T) {
        registerDependency(type: type, scope: .transient, factory: factory)
    }
}

public protocol Assembly {
    func assemble(dependencyResolving: DependencyResolving)
}

public final class DependencyInjector: DependencyResolving {
    private struct DependencyProvider<T> {
        let scope: ResolutionScope
        let factory: (DependencyResolving) -> T
    }
    
    private let lock = NSLock()
    private var transientProviders: [String: Any] = [:]
    private var singletonInstances: [String: Any] = [:]
    private var weaklyHeldInstances: [String: WeakReference<AnyObject>] = [:]
    
    func setupAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(dependencyResolving: self) }
    }
    
    public func registerDependency<T>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving) -> T) {
        lock.lock()
        defer { lock.unlock() }
        
        let dependencyProvider = DependencyProvider(scope: scope, factory: factory)
        transientProviders[String(describing: T.self)] = dependencyProvider
    }
    
    public func resolveDependency<T>() -> T {
        lock.lock()
        defer { lock.unlock() }
        let typeName = String(describing: T.self)
        
        let dependencyProvider = transientProviders[typeName]
        
        guard let dependencyProvider = dependencyProvider as? DependencyProvider<T> else {
            fatalError("The resolver for type \(T.self) has not been registered")
        }
        
        switch dependencyProvider.scope {
        case .transient:
            return dependencyProvider.factory(self)
            
        case .singleton:
            return {
                guard let permanentInstance = singletonInstances[typeName] as? T else {
                    let instance = dependencyProvider.factory(self)
                    singletonInstances[String(describing: T.self)] = instance
                    return instance
                }
                return permanentInstance
            }()
            
        case .weak:
            if let instance = self.weaklyHeldInstances[typeName]?.value as? T {
                return instance
            } else {
                let instance = dependencyProvider.factory(self)
                let weakReference = WeakReference(value: instance as AnyObject)
                weaklyHeldInstances[typeName] = weakReference
                return instance
                
            }
        }
    }
}

private class WeakReference<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}
