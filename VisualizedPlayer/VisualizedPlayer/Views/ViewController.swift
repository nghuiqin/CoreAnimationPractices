//
//  ViewController.swift
//  VisualizedPlayer
//
//  Created by Hui Qin Ng on 2019/7/30.
//  Copyright © 2019 Hui Qin Ng. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private var player: AVAudioPlayer!
    private let visualizer = VisualizerView()
    private let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let firstSongURL = Bundle.main.url(forResource: "bensound-summer", withExtension: "mp3")!
    private let secondSongURL = Bundle.main.url(forResource: "DemoSong", withExtension: "m4a")!

    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .longFormAudio, options: .defaultToSpeaker)
        try? AVAudioSession.sharedInstance().setActive(true)


        super.init(nibName: nil, bundle: nil)
        title = "Music Visualizer"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        visualizer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(visualizer)

        // Setup Toolbar
        navigationController?.setToolbarHidden(false, animated: false)
        setupBarItems()
        setupSegmentedControl()
        playURL(url: firstSongURL)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        visualizer.frame = view.bounds
    }

    private func setupSegmentedControl() {
        let segmentControl = UISegmentedControl(items: ["First song", "Second song"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)

        navigationItem.titleView = segmentControl
    }

    private func setupBarItems(isPlay: Bool = false) {
        let middleButton = UIBarButtonItem(
            barButtonSystemItem: isPlay ? .pause : .play,
            target: self,
            action: isPlay ? #selector(pause) : #selector(play)
        )
        toolbarItems = [space, middleButton, space]
    }

    private func playURL(url: URL) {
        if player != nil && player.isPlaying {
            pause()
        }
        player = try! AVAudioPlayer(contentsOf: url)
        player.isMeteringEnabled = true
        player.numberOfLoops = .max
        player.prepareToPlay()
        visualizer.audioPlayer = player
    }

    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if segment.selectedSegmentIndex == 0 {
            playURL(url: firstSongURL)
            return
        }
        playURL(url: secondSongURL)
    }

    @objc func play() {
        player.play()
        setupBarItems(isPlay: true)
    }

    @objc func pause() {
        player.pause()
        setupBarItems(isPlay: false)
    }

}

