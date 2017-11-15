//
//  SegmentedViewController.swift
//  makeshift-connect
//
//  Created by Chris Werner on 2017-10-30.
//  Copyright © 2017 AppColony. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {
    
    private let extendedNavigationBar = UINavigationBar()
    private var segmentedControl: UISegmentedControl!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.scrollsToTop = false
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.primaryBackgroundColor()
        return scrollView
    }()
    private let viewContainer = UIView()
    
    private var currentViewController: UIViewController?
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        
        viewControllers.forEach { self.addChildViewController($0) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSegmentedControl()
        addViews()
        addConstraints()
        addChildren()
        showChildViewController(at: 0, animated: false)
    }
    
    private func initializeSegmentedControl() {
        segmentedControl = UISegmentedControl(items: childViewControllers.map { $0.title ?? "" })
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueDidChange(_:)), for: .valueChanged)
    }
    
    private func addViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(viewContainer)
        
        view.addSubview(extendedNavigationBar)
        extendedNavigationBar.addSubview(segmentedControl)
    }
    
    private func addConstraints() {
        if #available(iOS 11, *) {
            addSafeConstraints()
        } else {
            addGuidedConstraints()
        }
    }
    
    @available(iOS 11.0, *)
    private func addSafeConstraints() {
        let guide = view.safeAreaLayoutGuide
        extendedNavigationBar.apply(constraints: [
            extendedNavigationBar.topAnchor.constraint(equalTo: guide.topAnchor),
            extendedNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            extendedNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        
        segmentedControl.apply(constraints: [
            segmentedControl.centerXAnchor.constraint(equalTo: extendedNavigationBar.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: extendedNavigationBar.centerYAnchor),
            ])
        
        scrollView.apply(constraints: [
            scrollView.topAnchor.constraint(equalTo: extendedNavigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            guide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
        
        viewContainer.pinEdgesToSuperview()
        viewContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    private func addGuidedConstraints() {
        extendedNavigationBar.apply(constraints: [
            extendedNavigationBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            extendedNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            extendedNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        
        segmentedControl.apply(constraints: [
            segmentedControl.centerXAnchor.constraint(equalTo: extendedNavigationBar.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: extendedNavigationBar.centerYAnchor),
            ])
        
        scrollView.apply(constraints: [
            scrollView.topAnchor.constraint(equalTo: extendedNavigationBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
            ])
        
        viewContainer.pinEdgesToSuperview()
        viewContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
    }
    
    private func addChildren() {
        var leftmostView: UIView?
        
        childViewControllers.forEach { child in
            self.viewContainer.addSubview(child.view)
         
            child.view.apply(constraints: [
                child.view.leftAnchor.constraint(equalTo: leftmostView?.rightAnchor ?? viewContainer.leftAnchor),
                child.view.topAnchor.constraint(equalTo: viewContainer.topAnchor),
                child.view.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor),
                child.view.heightAnchor.constraint(equalTo: viewContainer.heightAnchor),
                child.view.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                ])
            
            leftmostView = child.view
        }
        
        if let leftmostView = leftmostView {
            leftmostView.rightAnchor.constraint(equalTo: viewContainer.rightAnchor).isActive = true
        }
    }
    
    @objc private func segmentedControlValueDidChange(_ segmentedControl: UISegmentedControl) {
        showChildViewController(at: segmentedControl.selectedSegmentIndex, animated: true)
    }
    
    func showChildViewController(at index: Int, animated: Bool) {
        guard index < childViewControllers.count else { return }
        
        let toViewController = childViewControllers[index]
        
        if toViewController != currentViewController {
            
            segmentedControl.selectedSegmentIndex = index
            
            makeChildren(hidden: false)
            
            toViewController.beginAppearanceTransition(true, animated: animated)
            currentViewController?.beginAppearanceTransition(false, animated: animated)
            
            let animations: () -> Void = {
                self.scrollView.contentOffset = toViewController.view.frame.origin
            }
            
            let completion: (Bool) -> Void = { finished in
                self.currentViewController?.endAppearanceTransition()
                toViewController.endAppearanceTransition()
                
                self.makeChildren(hidden: true, except: toViewController)
                
                self.currentViewController = toViewController
            }
            
            if animated {
                UIView.animate(withDuration: 0.3, animations: animations, completion: completion)
            } else {
                animations()
                completion(true)
            }
        }
    }
    
    //Used to ensure scrollsToTop works on children in iOS versions older than 11
    private func makeChildren(hidden: Bool, except exception: UIViewController? = nil) {
        childViewControllers.forEach { $0.view.isHidden = hidden }
        exception?.view.isHidden = !hidden
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

