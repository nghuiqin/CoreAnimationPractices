//
//  Bird.swift
//  CAFlappyBird
//
//  Created by Hui Qin Ng on 7/29/19.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

private let birdDropY: CGFloat = 2
private let birdFlyY: CGFloat = 80

class Bird: CALayer {
    enum State: String {
        case up = "redbird-upflap"
        case mid = "redbird-midflap"
        case down = "redbird-downflap"
    }

    var state: State = .down {
        didSet {
            contents = UIImage(named: state.rawValue)?.cgImage
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
        contents = UIImage(named: State.mid.rawValue)?.cgImage
        contentsGravity = .resizeAspectFill
    }

    func animate() {
        switch state {
        case .up: state = .mid
        case .mid: state = .down
        case .down: state = .up
        }
    }

    func fly() {
        frame.origin.y -= birdFlyY
    }

    func gravity() {
        frame.origin.y += birdDropY
    }

    func drop() {
        frame.origin.y = UIScreen.main.bounds.height
    }
}
