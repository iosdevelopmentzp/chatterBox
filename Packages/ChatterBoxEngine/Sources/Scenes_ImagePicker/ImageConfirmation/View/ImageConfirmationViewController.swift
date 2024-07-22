//
//  ImageConfirmationViewController.swift
//
//
//  Created by Dmytro Vorko on 22/07/2024.
//

import UIKit
import SwiftUI

public class ImageConfirmationViewController: UIViewController {
    private var hostingController: UIHostingController<ImageConfirmationView>
    
    public init(viewModel: ImageConfirmationViewModel) {
        self.hostingController = .init(rootView: ImageConfirmationView(viewModel: viewModel))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set the constraints for the hosting controller's view
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
