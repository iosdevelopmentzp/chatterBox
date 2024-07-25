//
//  UITableView+Dequeue.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import UIKit

public extension UITableView {
    /// Registers a UITableViewCell subclass conforming to Reusable.
    func registerCellClass<T: UITableViewCell>(_ cellType: T.Type) where T: Reusable {
        register(cellType, forCellReuseIdentifier: cellType.identifier)
    }

    /// Dequeues a reusable UITableViewCell conforming to Reusable.
    func dequeueReusableCell<T: UITableViewCell>(
        ofType cellType: T.Type,
        for indexPath: IndexPath
    ) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with identifier \(cellType.identifier)")
        }
        return cell
    }
}
