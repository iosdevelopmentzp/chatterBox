//
//  NavigationCoordinator.swift
//  
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import UIKit

open class NavigationCoordinator: CoordinatorProtocol {
    // MARK: - Properties
    
    let navigationController: UINavigationController
    public private(set) var children: [CoordinatorProtocol] = []
    
    // MARK: - Constructor
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Functions
    
    public func start() {
        fatalError("This method must be overridden")
    }
    
    public func addChild(_ child: CoordinatorProtocol) {
        children.append(child)
    }
    
    public func childDidFinish(_ child: CoordinatorProtocol) {
        children = children.filter { $0 !== child }
    }
}
