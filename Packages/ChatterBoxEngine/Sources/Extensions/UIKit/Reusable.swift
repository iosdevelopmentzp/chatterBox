//
//  Reusable.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import Foundation

public protocol Reusable {
    static var identifier: String { get }
}

public extension Reusable {
    static var identifier: String {
        return String(describing: self)
    }
}
