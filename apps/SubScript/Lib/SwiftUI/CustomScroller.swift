//
//  Scroller.swift
//  Superscript
//
//  Created by Colbyn Wadman on 3/1/22.
//

import SwiftUI


#if os(macOS)
final class FlippedClipView: NSClipView {
    override var isFlipped: Bool {
        return true
    }
}
#endif

fileprivate final class CustomScrollerViewController<Wrapped: View>: UI.LL.ViewController {
    fileprivate var subView: Wrapped!
    fileprivate var scrollView = UI.LL.ScrollView()
    fileprivate var embeddedViewCtl: UI.LL.HostingController<Wrapped>!
#if os(iOS)
    private func initViews() {
        // MARK: SCROLL-VIEW
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bouncesZoom = false
        scrollView.decelerationRate = UI.LL.ScrollView.DecelerationRate.fast
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
        embeddedViewCtl = UI.LL.HostingController(rootView: subView)
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
#elseif os(macOS)
    override func loadView() {
        self.view = NSView()
        self.view.autoresizingMask = [.width, .height]
        self.view.autoresizesSubviews = true
    }
    private func initViews() {
        // MARK: SCROLL-VIEW
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])
        // Initial clip view
        let clipView = FlippedClipView()
        clipView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentView = clipView
        scrollView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .left,
            relatedBy: .equal,
            toItem: scrollView,
            attribute: .left,
            multiplier: 1.0,
            constant: 0
        ))
        scrollView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .top,
            relatedBy: .equal,
            toItem: scrollView,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        ))
        scrollView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .right,
            relatedBy: .equal,
            toItem: scrollView,
            attribute: .right,
            multiplier: 1.0,
            constant: 0
        ))
        scrollView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: scrollView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        ))
        // Initial document view
        let documentView = NSView()
        documentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView
        clipView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .left,
            relatedBy: .equal,
            toItem: documentView,
            attribute: .left,
            multiplier: 1.0,
            constant: 0
        ))
        clipView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .top,
            relatedBy: .equal,
            toItem: documentView,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        ))
        clipView.addConstraint(NSLayoutConstraint(
            item: clipView,
            attribute: .right,
            relatedBy: .equal,
            toItem: documentView,
            attribute: .right,
            multiplier: 1.0,
            constant: 0
        ))
        // MARK: CHILD COMPONENTS
        embeddedViewCtl = UI.LL.HostingController(rootView: subView)
        self.addChild(embeddedViewCtl)
        embeddedViewCtl.view.translatesAutoresizingMaskIntoConstraints = false
        documentView.addSubview(embeddedViewCtl.view)
        NSLayoutConstraint.activate([
            documentView.topAnchor.constraint(equalTo: embeddedViewCtl.view.topAnchor),
            documentView.bottomAnchor.constraint(equalTo: embeddedViewCtl.view.bottomAnchor),
            documentView.leftAnchor.constraint(equalTo: embeddedViewCtl.view.leftAnchor),
            documentView.rightAnchor.constraint(equalTo: embeddedViewCtl.view.rightAnchor),
        ])
    }
#endif

    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
}

struct CustomScroller<V: View>: View {
    private var subview: () -> V
    init(@ViewBuilder _ view: @escaping () -> V) {
        self.subview = view
    }
    var body: some View {
        WrapViewController(onUpdate: { wrapped, ctx in
            let scroller = wrapped as! CustomScrollerViewController<V>
            scroller.embeddedViewCtl.rootView = self.subview()
        }){ ctx in
            let scroller: CustomScrollerViewController<V> = CustomScrollerViewController()
            scroller.subView = self.subview()
            return scroller
        }
    }
}

