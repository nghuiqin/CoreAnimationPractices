//
//  VisualizerView.swift
//  VisualizedPlayer
//
//  Created by Hui Qin Ng on 2019/7/30.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit
import AVFoundation

class VisualizerView: UIView {
    private let meterTable = MeterTable()
    private var timer: CADisplayLink!

    var audioPlayer: AVAudioPlayer!

    override class var layerClass: AnyClass {
        return CAEmitterLayer.self
    }

    override var layer: CAEmitterLayer {
        return super.layer as! CAEmitterLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.emitterPosition = center
        layer.emitterSize = CGSize(width: frame.width, height: frame.height/2)
        layer.emitterShape = .rectangle
        layer.renderMode = .additive

        let childCell = CAEmitterCell()
        childCell.name = "childCell"
        childCell.lifetime = 1/60
        childCell.birthRate = 60
        childCell.velocity = 0
        childCell.contents = UIImage(named: "particleTexture")?.cgImage

        let cell = CAEmitterCell()
        cell.emitterCells = [childCell]
        cell.name = "cell"
        cell.color = UIColor.yellow.cgColor
        cell.redRange = 0.46
        cell.greenRange = 0.39
        cell.blueRange = 0.67
        cell.alphaRange = 0.75

        cell.redSpeed = 0.14
        cell.greenSpeed = 0.08
        cell.blueSpeed = 0.015
        cell.alphaSpeed = -0.20

        cell.scale = 0.5
        cell.scaleRange = 0.5

        cell.lifetime = 1
        cell.lifetimeRange = 0.25
        cell.birthRate = 60

        cell.velocity = 100
        cell.velocityRange = 300
        cell.emissionRange = .pi * 2

        layer.emitterCells = [cell]

        timer = CADisplayLink(target: self, selector: #selector(update))
        timer.add(to: RunLoop.current, forMode: .common)
    }

    @objc func update() {

        var scale: Float = 0.5
        assert(audioPlayer != nil, "Please set audioPlayer into visualizer")
        if audioPlayer.isPlaying {
            audioPlayer.updateMeters()

            var power: Float = 0
            for index in 0..<audioPlayer.numberOfChannels {
                power += audioPlayer.averagePower(forChannel: index)
            }
            power /= Float(audioPlayer.numberOfChannels)

            let level = meterTable!.ValueAt(power)
            scale = level * 6
        }
        layer.setValue(scale, forKeyPath: "emitterCells.cell.emitterCells.childCell.scale")
    }

}
