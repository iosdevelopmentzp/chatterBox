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
    func resolveDependency<T, Params>(type: T.Type, parameters: Params) -> T
    func registerDependency<T>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving) -> T)
    func registerDependency<T, Params>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving, Params) -> T)
}

extension DependencyResolving {
    func registerDependency<T>(type: T.Type, factory: @escaping (DependencyResolving) -> T) {
        registerDependency(type: type, scope: .transient, factory: factory)
    }
}

public protocol Assembly {
    func assemble(resolver: DependencyResolving)
}

public final class DependencyInjector: DependencyResolving {
    private struct DependencyProvider<T> {
        let scope: ResolutionScope
        let factory: (DependencyResolving) -> T
    }
    
    private struct ParameterizedProvider<T, Param> {
        let scope: ResolutionScope
        let factory: (DependencyResolving, Param) -> T
    }
    
    private let lock = NSRecursiveLock()
    private var transientProviders: [ObjectIdentifier: Any] = [:]
    private var singletonInstances: [ObjectIdentifier: Any] = [:]
    private var weaklyHeldInstances: [ObjectIdentifier: WeakReference<AnyObject>] = [:]
    
    public init() {}
    
    public func setupAssemblies(_ assemblies: [Assembly]) {
        assemblies.forEach { $0.assemble(resolver: self) }
    }
    
    public func registerDependency<T>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving) -> T) {
        lock.lock()
        defer { lock.unlock() }
        let dependencyProvider = DependencyProvider(scope: scope, factory: factory)
        transientProviders[ObjectIdentifier(T.self)] = dependencyProvider
    }
    
    public func registerDependency<T, Params>(type: T.Type, scope: ResolutionScope, factory: @escaping (DependencyResolving, Params) -> T) {
        lock.lock()
        defer { lock.unlock() }
        let provider = ParameterizedProvider(scope: scope, factory: factory)
        transientProviders[ObjectIdentifier(T.self)] = provider
    }
    
    public func resolveDependency<T, Params>(type: T.Type, parameters: Params) -> T {
        lock.lock()
        defer { lock.unlock() }
        let identifier = ObjectIdentifier(T.self)
        
        let dependencyProvider = transientProviders[identifier]
        
        guard let dependencyProvider = dependencyProvider as? ParameterizedProvider<T, Params> else {
            fatalError("The resolver for type \(T.self) has not been registered")
        }
        
        switch dependencyProvider.scope {
        case .transient:
            return dependencyProvider.factory(self, parameters)
            
        case .singleton:
            if let singletonInstance = singletonInstances[identifier] as? T {
                return singletonInstance
            } else {
                let instance = dependencyProvider.factory(self, parameters)
                singletonInstances[identifier] = instance
                return instance
            }
            
        case .weak:
            let instance = dependencyProvider.factory(self, parameters)
            let weakReference = WeakReference(value: instance as AnyObject)
            weaklyHeldInstances[identifier] = weakReference
            return instance
        }
    }
    
    public func resolveDependency<T>() -> T {
        lock.lock()
        defer { lock.unlock() }
        let identifier = ObjectIdentifier(T.self)
        
        let dependencyProvider = transientProviders[identifier]
        
        guard let dependencyProvider = dependencyProvider as? DependencyProvider<T> else {
            fatalError("The resolver for type \(T.self) has not been registered")
        }
        
        switch dependencyProvider.scope {
        case .transient:
            return dependencyProvider.factory(self)
            
        case .singleton:
            if let singletonInstance = singletonInstances[identifier] as? T {
                return singletonInstance
            } else {
                let instance = dependencyProvider.factory(self)
                singletonInstances[identifier] = instance
                return instance
            }
            
        case .weak:
            if let instance = self.weaklyHeldInstances[identifier]?.value as? T {
                return instance
            } else {
                let instance = dependencyProvider.factory(self)
                let weakReference = WeakReference(value: instance as AnyObject)
                weaklyHeldInstances[identifier] = weakReference
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
