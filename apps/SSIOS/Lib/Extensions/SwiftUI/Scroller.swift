//
//  Scroller.swift
//  Superscript
//
//  Created by Colbyn Wadman on 3/1/22.
//

import SwiftUI
import UIKit


struct CustomScroller<Wrapped: View>: UIViewControllerRepresentable {
    typealias UIViewControllerType = CustomScrollerViewController<Wrapped>
    
    private var customScrollerCoordinator: CustomScrollerCoordinator<Wrapped> = CustomScrollerCoordinator()
    private var subView: Wrapped
    
    init(_ setup: @escaping (CustomScrollerCoordinator<Wrapped>) -> Wrapped) {
        self.customScrollerCoordinator = CustomScrollerCoordinator()
        self.subView = setup(self.customScrollerCoordinator)
    }

    func makeUIViewController(context: Self.Context) -> Self.UIViewControllerType {
        let ctl: CustomScrollerViewController<Wrapped> = CustomScrollerViewController()
        customScrollerCoordinator.customScrollerViewController = ctl
        ctl.subView = subView
        return ctl
    }

    func updateUIViewController(_ ctl: Self.UIViewControllerType, context: Self.Context) {
        
    }
    
    func makeCoordinator() -> CustomScrollerCoordinator<Wrapped> {
        self.customScrollerCoordinator
    }
}

class CustomScrollerCoordinator<Wrapped: View>: ObservableObject {
    var customScrollerViewController: CustomScrollerViewController<Wrapped>!
}



class CustomScrollerViewController<Wrapped: View>: UIViewController {
    fileprivate var customScrollerCoordinator: CustomScrollerCoordinator<Wrapped>!
    fileprivate var subView: Wrapped!
    fileprivate var scrollView = UIScrollView()
    fileprivate var contentView = UIStackView()
    
    var embeddedViewCtl: UIHostingController<Wrapped>!

    private func initViews() {
        // MARK: SCROLL-VIEW
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bouncesZoom = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.panGestureRecognizer.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.direct.rawValue)
        ]
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        // MARK: CHILD COMPONENTS
        embeddedViewCtl = UIHostingController(rootView: subView)
        embeddedViewCtl.view.backgroundColor = UIColor.clear
        embeddedViewCtl.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(embeddedViewCtl)
        scrollView.addSubview(embeddedViewCtl.view)
        
        NSLayoutConstraint.activate([
            embeddedViewCtl.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            embeddedViewCtl.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            embeddedViewCtl.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            embeddedViewCtl.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
        embeddedViewCtl.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}




