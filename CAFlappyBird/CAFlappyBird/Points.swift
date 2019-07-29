//
//  Points.swift
//  CAFlappyBird
//
//  Created by Hui Qin Ng on 7/29/19.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

private let pointWidth: CGFloat = 16
private let pointHeight: CGFloat = 36

class Point: CALayer {
    var value: Character = "0" {
        didSet {
            contents = UIImage(named: String(value))?.cgImage
        }
    }
    
    override init() {
        super.init()
        setupLayers()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        contents = UIImage(named: "0")?.cgImage
    }
}

class Points: CALayer {
    var point: Int = 0 {
        didSet {
            var result = String(point)
            if result.count < 4 {
                let resultFirstCharacter = result.first!
                result.insert(
                    contentsOf: Array(repeating: "0", count: 4 - result.count),
                    at: result.firstIndex(of: resultFirstCharacter)!
                )
            } else if result.count > 4 {
                result = "9999"
            }
            
            result.enumerated().forEach { (arg) in
                let (index, value) = arg
                pointsLayer[index].value = value
            }
        }
    }
    private var pointsLayer: [Point] = []
    
    override init() {
        super.init()
        setupLayers()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        frame = CGRect(x: 0, y: 0, width: pointWidth * 4, height: pointHeight)
        for index in 0...3 {
            let offset = CGFloat(index) * pointWidth
            let layer = Point()
            layer.frame = CGRect(x: offset, y: 0, width: pointWidth, height: pointHeight)
            addSublayer(layer)
            pointsLayer.append(layer)
        }
    }
}
