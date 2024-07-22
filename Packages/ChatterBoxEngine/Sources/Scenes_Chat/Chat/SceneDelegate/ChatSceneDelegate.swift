//
//  ChatSceneDelegate.swift
//
//
//  Created by Dmytro Vorko on 20/07/2024.
//

import Foundation

public protocol ChatSceneDelegate: AnyObject {
    func didTapAttachImages(completion: @escaping ([String]) -> Void)
}
