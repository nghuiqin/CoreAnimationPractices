//
//  Pipe.swift
//  CAFlappyBird
//
//  Created by Hui Qin Ng on 7/29/19.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

class Pipe: CALayer {
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
        contents = UIImage(named: "pipe-green")?.cgImage
        contentsGravity = .resizeAspectFill
    }
    
    func flip() {
        transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
    }
}
