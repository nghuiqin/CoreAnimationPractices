//
//  ViewController.swift
//  CAFlappyBird
//
//  Created by Hui Qin Ng on 2019/7/29.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

private let birdWidth: CGFloat = 51
private let birdHeight: CGFloat = 36
private let birdOriginX = floor((UIScreen.main.bounds.width - birdWidth)/2)
private let birdOriginY = floor((UIScreen.main.bounds.height - birdHeight)/2)
private let birdDropY: CGFloat = 2
private let baseHeight = floor(UIScreen.main.bounds.width / 336 * 112)
private let baseOriginY = UIScreen.main.bounds.height - baseHeight
private let pipeWidth: CGFloat = 78
private let pipeHeight: CGFloat = 480
private let pipeHorizontalDistance: CGFloat = 180
private let pipeVerticalDistance: CGFloat = 160
private let pipMinHeight = UIScreen.main.bounds.height - pipeHeight - baseHeight - pipeVerticalDistance
private let pipeMaxHeight = pipeHeight

private let gameOverWidth: CGFloat = 192
private let gameOverHeight: CGFloat = 42
private let gameOverOriginX = floor((UIScreen.main.bounds.width - gameOverWidth)/2)
private let gameOverOriginY = floor((UIScreen.main.bounds.height - baseHeight - gameOverHeight)/2)


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
        frame.origin.y -= 80
    }

    func gravity() {
        frame.origin.y += birdDropY
    }

    func drop() {
        frame.origin.y = UIScreen.main.bounds.height
    }
}

class ViewController: UIViewController {

    enum GameState {
        case idle
        case running
        case gameOver
        case restart
    }

    private let bird = Bird()
    private let baseLayer = CALayer()
    private let gameOverLayer = CALayer()
    private var timer: CADisplayLink?
    private var counter: Int = 0
    private var pipes: [CALayer] = []
    private var state: GameState = .idle {
        didSet {
            switch state {
            case .gameOver:
                gameOverLayer.isHidden = false
                stopTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.bird.drop()
                    self.state = .restart
                }

            case .idle:
                gameOverLayer.isHidden = true
                pipes.forEach { $0.removeFromSuperlayer() }
                pipes.removeAll()
                initialGame()

            case .running:
                startTimer()

            default:
                break
            }
        }
    }

    deinit {
        stopTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGesture()
    }

    private func setupViews() {
        view.backgroundColor = .systemTeal

        baseLayer.contents = UIImage(named: "base")?.cgImage
        baseLayer.frame = CGRect(x: 0, y: baseOriginY, width: UIScreen.main.bounds.width, height: baseHeight)
        view.layer.addSublayer(baseLayer)

        view.layer.insertSublayer(bird, above: baseLayer)

        gameOverLayer.contents = UIImage(named: "gameover")?.cgImage
        gameOverLayer.frame = CGRect(x: gameOverOriginX, y: gameOverOriginY, width: gameOverWidth, height: gameOverHeight)
        view.layer.addSublayer(gameOverLayer)

        initialGame()
    }

    private func initialGame() {
        gameOverLayer.isHidden = true

        bird.frame = CGRect(x: birdOriginX, y: birdOriginY, width: birdWidth, height: birdHeight)

        let offset: CGFloat = UIScreen.main.bounds.width
        for index in 0..<30 {
            let height = floor(CGFloat.random(in: pipMinHeight...pipeMaxHeight))
            let originX = (pipeWidth + pipeHorizontalDistance) * CGFloat(index) + offset
            let upperPipeLayer = CALayer()
            let lowerPipeLayer = CALayer()
            upperPipeLayer.contents = UIImage(named: "pipe-green")?.cgImage
            lowerPipeLayer.contents = UIImage(named: "pipe-green")?.cgImage
            upperPipeLayer.frame = CGRect(x: originX, y: height - pipeHeight, width: pipeWidth, height: pipeHeight)
            upperPipeLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            lowerPipeLayer.frame = CGRect(x: originX, y: height + pipeVerticalDistance, width: pipeWidth, height: pipeHeight)
            view.layer.insertSublayer(upperPipeLayer, below: baseLayer)
            view.layer.insertSublayer(lowerPipeLayer, below: baseLayer)
            pipes.append(upperPipeLayer)
            pipes.append(lowerPipeLayer)
        }
    }

    private func setupGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            view.addGestureRecognizer(tap)
        }

    private func startTimer() {
        timer = CADisplayLink(target: self, selector: #selector(handleNextFrameState))
        timer?.add(to: RunLoop.current, forMode: .default)
    }

    private func stopTimer() {
        timer?.remove(from: RunLoop.current, forMode: .default)
        timer?.invalidate()
    }

    @objc func handleNextFrameState() {
        CATransaction.begin()
        CATransaction.disableActions()
        // Trigger bird flying animation
        counter += 1
        if counter % 6 == 0 {
            bird.animate()
        }
        counter %= 6

        bird.gravity()

        if bird.frame.origin.y >= UIScreen.main.bounds.height - baseHeight {
            return
        }

        pipes.forEach { pipe in
            pipe.frame.origin.x -= 1
            if pipe.frame.intersects(bird.frame) && (pipe.frame.intersection(bird.frame).size.width > 20 ||
                pipe.frame.intersection(bird.frame).size.height > 20) {
                state = .gameOver
            }
        }

        CATransaction.commit()
    }

    @objc func handleTap() {
        switch state {
        case .running:
            bird.fly()

        case .restart:
            state = .idle

        case .idle:
            state = .running

        default:
            break
        }
    }

}

