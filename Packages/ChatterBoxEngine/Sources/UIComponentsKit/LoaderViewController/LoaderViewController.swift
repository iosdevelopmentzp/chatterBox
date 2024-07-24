//
//  LoaderViewController.swift
//
//
//  Created by Dmytro Vorko on 24/07/2024.
//

import UIKit

public class LoaderViewController: UIViewController {
    private var activityIndicator: UIActivityIndicatorView!
    private let loaderTransDelegate = LoaderTransitioningDelegate()
    
    public init() {
        super.init(nibName: nil, bundle:  nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = loaderTransDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func present(from viewController: UIViewController, completion: (() -> Void)?) {
        viewController.present(self, animated: true, completion: completion)
    }
    
    public func dismissLoader(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
}


class LoaderTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LoaderPresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return LoaderDismissalAnimator()
    }
}

class LoaderPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) as? LoaderViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.alpha = 1
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

class LoaderDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? LoaderViewController else {
            transitionContext.completeTransition(false)
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromViewController.view.alpha = 0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
