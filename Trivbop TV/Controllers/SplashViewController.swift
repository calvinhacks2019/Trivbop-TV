//
//  SplashViewController.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit
import AVFoundation

class SplashViewController: UIViewController {
    var background: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        playSound()
    }

    func playSound() {
        guard let path = Bundle.main.path(forResource: "background.mp3", ofType: nil)
             else { return }
        let url = URL(fileURLWithPath: path)

        do {
            background = try AVAudioPlayer(contentsOf: url)
            background?.numberOfLoops = -1
            background?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
