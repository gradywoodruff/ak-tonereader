//
//  ViewController.swift
//  ToneReader
//
//  Created by Mike on 11/23/19.
//  Copyright © 2019 Mike. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController, EZMicrophoneDelegate {
    
    var audioManager = AudioManager.sharedInstance
    @IBOutlet weak var audioPlot: AKOutputWaveformPlot!
    
    var lastTime = Date()
    public var isConnected = false
    public var isNotConnected: Bool { return !isConnected }
    internal var bufferSize: UInt32 = 1_024
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [unowned self] (timer) in
            print(self.audioManager.tracker.amplitude)
            self.setupNode(AudioKit.output)
        }
        
        audioPlot.color = .label
        audioPlot.plotType = .buffer
        audioPlot.shouldMirror = false
        audioPlot.shouldFill = false
    }
    
    internal func setupNode(_ input: AKNode?) {
        if !isConnected {
            input?.avAudioNode.installTap(
                onBus: 0,
                bufferSize: bufferSize,
                format: nil) { [weak self] (buffer, _) in

                    guard let strongSelf = self else {
                        AKLog("Unable to create strong reference to self")
                        return
                    }
                    buffer.frameLength = strongSelf.bufferSize
                    let offset = Int(buffer.frameCapacity - buffer.frameLength)
                    if let tail = buffer.floatChannelData?[0] {
                        self?.audioPlot.updateBuffer(&tail[offset], withBufferSize: strongSelf.bufferSize)
                    }
            }
        }
        isConnected = true
    }
}

extension ViewController {
    func microphone(_ microphone: AKMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, atTime timestamp: UnsafePointer<AudioTimeStamp>!) {
        guard Date().timeIntervalSince(lastTime) > 0.06 else { return }
        lastTime = Date()
        DispatchQueue.main.async {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
}
