//
//  NSLayoutConstraint+Extra.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import UIKit

public extension NSLayoutConstraint {
    func setPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
    
    func linkToReference(_ reference: inout NSLayoutConstraint?) -> Self {
        reference = self
        return self
    }
}
