//
//  Collection+SafeSubscript.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
