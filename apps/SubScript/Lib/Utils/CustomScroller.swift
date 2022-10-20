//
//  Scroller.swift
//  Superscript
//
//  Created by Colbyn Wadman on 3/1/22.
//

import SwiftUI

fileprivate class CustomScrollerViewController<Wrapped: View>: UI.ViewController {
    fileprivate var subView: Wrapped!
//    fileprivate var customScrollerCoordinator: CustomScrollerCoordinator<Wrapped>!
    private var scrollView = UI.ScrollView()
    private var contentView = UI.StackView()
    private var embeddedViewCtl: UI.HostingController<Wrapped>!

    private func initViews() {
        // MARK: SCROLL-VIEW
        scrollView.translatesAutoresizingMaskIntoConstraints = false
#if os(iOS)
        scrollView.bouncesZoom = false
        scrollView.decelerationRate = UI.ScrollView.DecelerationRate.fast
        scrollView.panGestureRecognizer.minimumNumberOfTouches = 2
        scrollView.panGestureRecognizer.allowedTouchTypes = [
            NSNumber(value: UITouch.TouchType.direct.rawValue)
        ]
#endif
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        // MARK: CHILD COMPONENTS
        embeddedViewCtl = UI.HostingController(rootView: subView)
#if os(iOS)
        embeddedViewCtl.view.backgroundColor = UI.Color.clear
#endif
        embeddedViewCtl.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(embeddedViewCtl)
        scrollView.addSubview(embeddedViewCtl.view)
        NSLayoutConstraint.activate([
            embeddedViewCtl.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            embeddedViewCtl.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            embeddedViewCtl.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            embeddedViewCtl.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
#if os(iOS)
        embeddedViewCtl.didMove(toParent: self)
#endif
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    class CustomScrollerCoordinator<Wrapped: View>: ObservableObject {
        var customScrollerViewController: CustomScrollerViewController<Wrapped>!
    }
}

struct CustomScroller<V: View>: View {
    private var subview: V
    init(@ViewBuilder _ view: @escaping () -> V) {
        self.subview = view()
    }
    var body: some View {
        WrapViewController {
            let scroller: CustomScrollerViewController<V> = CustomScrollerViewController()
            scroller.subView = self.subview
            return scroller
        }
    }
}

