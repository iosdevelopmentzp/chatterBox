//
//  CoordinatorProtocol.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

public protocol CoordinatorProtocol: AnyObject {
    var parent: CoordinatorProtocol? { get }
    var children: [CoordinatorProtocol] { get }
    
    func start()
    func addChild(_ child: CoordinatorProtocol)
    func childDidFinish(_ child: CoordinatorProtocol)
    func didFinish()
}
