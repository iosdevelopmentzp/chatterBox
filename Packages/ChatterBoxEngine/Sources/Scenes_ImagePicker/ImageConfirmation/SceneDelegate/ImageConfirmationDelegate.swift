//
//  ImageConfirmationDelegate.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import Foundation

public protocol ImageConfirmationDelegate: AnyObject {
    func didTapCancel()
    func didConfirm(urls: [String])
}
