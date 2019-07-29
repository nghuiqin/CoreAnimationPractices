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
private let baseHeight = floor(UIScreen.main.bounds.width / 336 * 112)
private let baseOriginY = UIScreen.main.bounds.height - baseHeight
private let pipeWidth: CGFloat = 78
private let pipeHeight: CGFloat = 480
private let pipeHorizontalDistance: CGFloat = 180
private let pipeVerticalDistance: CGFloat = 160
private let pipeMinHeight = UIScreen.main.bounds.height - pipeHeight - baseHeight - pipeVerticalDistance
private let pipeMaxHeight = pipeHeight
private let gameOverWidth: CGFloat = 192
private let gameOverHeight: CGFloat = 42
private let gameOverOriginX = floor((UIScreen.main.bounds.width - gameOverWidth)/2)
private let gameOverOriginY = floor((UIScreen.main.bounds.height - baseHeight - gameOverHeight)/3)

class ViewController: UIViewController {

    // MARK: - Properties
    enum GameState {
        case idle
        case running
        case gameOver
        case restart
    }

    private let bird = Bird()
    private let baseLayer = CALayer()
    private let gameOverLayer = CALayer()
    private let pointsLayer = Points()
    private var timer: CADisplayLink?
    private var flyAnimationCounter: Int = 0
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
    
    private var gamePoint: Int = 0 {
        didSet {
            pointsLayer.point = gamePoint
        }
    }
    
    // MARK: - Lifecycle

    deinit {
        stopTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGesture()
    }
    
    // MARK: - Initializers
    
    private func setupViews() {
        view.backgroundColor = .systemTeal

        baseLayer.contents = UIImage(named: "base")?.cgImage
        baseLayer.frame = CGRect(x: 0, y: baseOriginY, width: UIScreen.main.bounds.width, height: baseHeight)
        view.layer.addSublayer(baseLayer)

        view.layer.insertSublayer(bird, above: baseLayer)

        gameOverLayer.contents = UIImage(named: "gameover")?.cgImage
        gameOverLayer.frame = CGRect(x: gameOverOriginX, y: gameOverOriginY, width: gameOverWidth, height: gameOverHeight)
        view.layer.addSublayer(gameOverLayer)
        
        view.layer.insertSublayer(pointsLayer, above: baseLayer)
        pointsLayer.frame.origin.x = 10
        pointsLayer.frame.origin.y = baseOriginY + 40

        initialGame()
    }

    private func initialGame() {
        gamePoint = 0
        gameOverLayer.isHidden = true

        bird.frame = CGRect(x: birdOriginX, y: birdOriginY, width: birdWidth, height: birdHeight)

        let offset: CGFloat = UIScreen.main.bounds.width
        for index in 0..<5 {
            let originX = (pipeWidth + pipeHorizontalDistance) * CGFloat(index) + offset
            createPipes(atOriginX: originX)
        }
    }
    
    private func createPipes(atOriginX originX: CGFloat) {
        let upperPipeVisibleHeight = floor(CGFloat.random(in: pipeMinHeight...pipeMaxHeight))
        let upperPipeLayer = Pipe()
        upperPipeLayer.frame = CGRect(
            x: originX,
            y: upperPipeVisibleHeight - pipeHeight,
            width: pipeWidth,
            height: pipeHeight
        )
        upperPipeLayer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        
        let lowerPipeLayer = Pipe()
        lowerPipeLayer.frame = CGRect(
            x: originX,
            y: upperPipeVisibleHeight + pipeVerticalDistance,
            width: pipeWidth,
            height: pipeHeight
        )
        
        view.layer.insertSublayer(upperPipeLayer, below: baseLayer)
        view.layer.insertSublayer(lowerPipeLayer, below: baseLayer)
        pipes.append(upperPipeLayer)
        pipes.append(lowerPipeLayer)
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }

    // MARK: - State handler
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

// MARK: - Timer
private extension ViewController {
    func startTimer() {
        timer = CADisplayLink(target: self, selector: #selector(handleNextFrameState))
        timer?.add(to: RunLoop.current, forMode: .default)
    }

    func stopTimer() {
        timer?.remove(from: RunLoop.current, forMode: .default)
        timer?.invalidate()
        timer = nil
    }

    @objc func handleNextFrameState() {
        let firstPipe = pipes.first!
        // Count Game Point
        if state == .running && firstPipe.frame.origin.x + pipeWidth == bird.frame.origin.x {
            gamePoint += 1
        }
        
        CATransaction.begin()
        CATransaction.disableActions()
        // Trigger bird flying animation
        flyAnimationCounter += 1
        if flyAnimationCounter % 6 == 0 {
            bird.animate()
        }
        flyAnimationCounter %= 6

        pipes.forEach { pipe in
            if pipe.frame.intersects(bird.frame) &&
                (pipe.frame.intersection(bird.frame).size.width > 10 &&
                pipe.frame.intersection(bird.frame).size.height > 10) {
                state = .gameOver
                return
            }
            pipe.frame.origin.x -= 1
        }
        
        bird.gravity()
        if bird.frame.origin.y >= UIScreen.main.bounds.height - baseHeight {
            state = .gameOver
            return
        }
        
        // Make pipes infinite
        if firstPipe.frame.origin.x < -(pipeWidth + 10) {
            pipes[0].removeFromSuperlayer()
            pipes[1].removeFromSuperlayer()
            pipes.removeFirst(2)
            let originX = pipes.last!.frame.origin.x + pipeWidth + pipeHorizontalDistance
            createPipes(atOriginX: originX)
        }

        CATransaction.commit()
    }
}

