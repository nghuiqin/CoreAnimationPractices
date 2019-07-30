//
//  ViewController.swift
//  LyricsHighlighter
//
//  Created by Hui Qin Ng on 2019/7/29.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit

private let lyrics = [
    "垂涎的邪惡",
    "陪我長大",
    "在軟爛中生長",
    "社會營養",
    "過去坑疤的",
    "讓我站穩了",
    "那些神醜的",
    "評誰亂正的",
    "喔",
    "我都笑哭了",
    "這什麼標準",
    "急著決定適者生存",
    "愛我恨我非我",
    "有一些外在我",
    "來自內在我",
    "聽誰說錯的對的",
    "說美的醜的",
    "若問我我看我說",
    "我怪美的",
    "看不見我的美",
    "是你瞎了眼",
    "稱讚的嘴臉",
    "卻轉身吐口水",
    "審美的世界",
    "誰有膽說那麼絕對",
    "真我假我自我看今天這個我",
    "想要哪個我",
    "聽誰說錯的對的",
    "說美的醜的",
    "若問我我看我說",
    "我怪美的",
    "誰來推我一把On to the next one",
    "一路背著太多道德活著令人會喘…"
]

private let textLayerHeight: CGFloat = 22
private let duration: TimeInterval = 2

class ViewController: UIViewController {

    private let textLayers = lyrics.map { lyric -> CATextLayer in
        let layer = CATextLayer()
        layer.string = lyric
        layer.fontSize = 14
        layer.alignmentMode = .center
        layer.foregroundColor = UIColor.white.cgColor
        return layer
    }

    private let scrollView = UIScrollView()
    private var timer: Timer?
    private var currentIndex: Int = NSNotFound

    deinit {
        stopTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupTimer()
    }

    private func setupViews() {
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .black
        view.addSubview(scrollView)

        var contentHeight: CGFloat = 64
        textLayers.forEach { layer in
            layer.frame = CGRect(x: 0, y: contentHeight, width: view.frame.width, height: textLayerHeight)

            scrollView.layer.addSublayer(layer)
            contentHeight += textLayerHeight
        }

        scrollView.contentSize = CGSize(width: view.bounds.size.width, height: contentHeight)
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if self.currentIndex == NSNotFound {
                self.currentIndex = 0
                self.updateTextLayer(at: 0, highLight: true)
            } else if self.currentIndex + 1 < self.textLayers.count {
                self.updateTextLayer(at: self.currentIndex, highLight: false)
                self.updateTextLayer(at: self.currentIndex + 1, highLight: true)
                self.currentIndex += 1
            } else {
                self.updateTextLayer(at: self.currentIndex, highLight: false)
                self.currentIndex = NSNotFound
                self.stopTimer()
            }
        })
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateTextLayer(at index: Int, highLight: Bool) {
        let layer = textLayers[index]
        layer.backgroundColor = highLight ? UIColor.white.cgColor : UIColor.black.cgColor
        layer.foregroundColor = highLight ? UIColor.black.cgColor : UIColor.white.cgColor
    }
}

