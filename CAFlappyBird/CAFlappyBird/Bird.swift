//
//  Bird.swift
//  CAFlappyBird
//
//  Created by Hui Qin Ng on 7/29/19.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

private let birdDropY: CGFloat = 4
private let birdFlyY: CGFloat = 100

class Bird: CALayer {
    enum AnimateState: String {
        case up = "redbird-upflap"
        case mid = "redbird-midflap"
        case down = "redbird-downflap"
    }

    var animateState: AnimateState = .down {
        didSet {
            contents = UIImage(named: animateState.rawValue)?.cgImage
        }
    }

    override init(layer: Any) {
        super.init(layer: layer)
        setupViews()
    }

    override init() {
        super.init()
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contents = UIImage(named: AnimateState.mid.rawValue)?.cgImage
        contentsGravity = .resizeAspectFill
    }

    func animate() {
        switch animateState {
        case .up: animateState = .mid
        case .mid: animateState = .down
        case .down: animateState = .up
        }
    }

    func fly() {
        frame.origin.y -= birdFlyY
//        print("Bird fly:", frame.origin.y)
    }

    func gravity() {
        frame.origin.y += birdDropY
//        print("Bird gravity:", frame.origin.y)
    }

    func drop() {
        frame.origin.y = UIScreen.main.bounds.height
    }
}
