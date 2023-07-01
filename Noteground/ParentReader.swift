//
//  ParentReader.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI

struct ParentReader: UIViewControllerRepresentable {
    private let handler: @MainActor (UIViewController?) -> Void
    
    init(handler: @MainActor @escaping (UIViewController?) -> Void) {
        self.handler = handler
    }
    
    @MainActor
    final class ViewController: UIViewController {
        var handler: @MainActor (UIViewController?) -> Void
        
        init(handler: @escaping (UIViewController?) -> Void) {
            self.handler = handler
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = false
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            handler(parent)
        }
    }
    
    func makeUIViewController(context: Context) -> ViewController {
        .init(handler: handler)
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.handler = handler
    }
}
