//
//  LottieView.swift
//  Tona
//
//  Created by Alma on 09/09/25.
//

import Foundation
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    var playOnAppear: Bool = true
    
    private let animationView = LottieAnimationView()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        if playOnAppear {
            animationView.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if playOnAppear {
            animationView.play()
        } else {
            animationView.stop()
        }
    }
}
