//
//  ViewController.swift
//  DSWaveformImageExample
//
//  Created by Dennis Schmidt on 06/02/2017.
//  Copyright © 2017 Dennis Schmidt. All rights reserved.
//

import UIKit
import DSWaveformImage

class ViewController: UIViewController {
    @IBOutlet weak var topWaveformView: UIImageView!
    @IBOutlet weak var middleWaveformView: WaveformImageView!
    @IBOutlet weak var bottomWaveformView: UIImageView!
    @IBOutlet weak var scrollWaveformView: UIScrollView!
    @IBOutlet weak var scrollWaveformViewContainer: UIView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let waveformImageDrawer = WaveformImageDrawer()
        let audioURL = Bundle.main.url(forResource: "example_sound", withExtension: "m4a")!

        // always uses background thread rendering
        waveformImageDrawer.waveformImage(fromAudioAt: audioURL,
                                          size: topWaveformView.bounds.size,
                                          style: .striped,
                                          position: .top) { image in
            // need to jump back to main queue
            DispatchQueue.main.async {
                self.topWaveformView.image = image
            }
        }

        middleWaveformView.waveformColor = UIColor.red
        middleWaveformView.waveformAudioURL = audioURL

        let configuration = WaveformConfiguration(size: bottomWaveformView.bounds.size,
                                                  color: UIColor.blue,
                                                  style: .filled,
                                                  position: .bottom)

        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: configuration) { image in
            DispatchQueue.main.async {
                self.bottomWaveformView.image = image
            }
        }

        // get access to the raw, normalized amplitude samples
        let waveformAnalyzer = WaveformAnalyzer(audioAssetURL: audioURL)
        waveformAnalyzer?.samples(count: 10) { samples in
            print("sampled down to 10, results are \(samples ?? [])")
        }

        // over 5460pt wide waveform image w/ scroll view
        let scrollContentSize = CGSize(width: 6000, height: scrollWaveformView.frame.height)
        let scrollViewConfig = WaveformConfiguration(size: scrollContentSize,
                                                     color: UIColor.darkGray,
                                                  style: .filled,
                                                  position: .middle)
        var scrollViewPosition: CGFloat = 0

        waveformImageDrawer.waveformImage(fromAudioAt: audioURL, with: scrollViewConfig) { [weak self] image in
            guard let image = image else { return }

            DispatchQueue.main.async {
                let iv = UIImageView(image: image)
                iv.frame.origin.x = scrollViewPosition
                scrollViewPosition += image.size.width
                self?.scrollWaveformViewContainer.addSubview(iv)

                // set scroll content size
                guard self?.scrollWaveformViewContainer.subviews.count == 1,
                    let height = self?.scrollWaveformView.frame.height else { return }

                let sizeFit = CGSize(width: scrollContentSize.width, height: height)
                self?.scrollWaveformView.contentSize = sizeFit
            }
        }
    }
}
