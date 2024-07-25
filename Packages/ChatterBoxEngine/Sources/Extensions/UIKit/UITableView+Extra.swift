//
//  UITableView+Extra.swift
//
//
//  Created by Dmytro Vorko on 25/07/2024.
//

import UIKit

public extension UITableView {
    /// Scrolls the table view to the first row in the first section.
    func scrollToTop(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        if self.numberOfSections > 0 && self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: indexPath, at: .top, animated: animated)
        }
    }
}
