//
//  File.swift
//  
//
//  Created by Dmytro Vorko on 24/07/2024.
//

import UIKit
import SwiftUI

public struct LoaderViewWrapper: UIViewControllerRepresentable {
    public func makeUIViewController(context: Context) -> LoaderViewController {
        let loaderViewController = LoaderViewController()
        return loaderViewController
    }
    
    public func updateUIViewController(_ uiViewController: LoaderViewController, context: Context) {
        
    }
}
