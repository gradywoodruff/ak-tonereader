//
//  AudioManager.swift
//  ToneReader
//
//  Created by Grady Woodruff on 12/8/19.
//  Copyright © 2019 Mike. All rights reserved.
//

import AudioKit
import AudioKitUI


class AudioManager {

    // Singleton of the AudioManager class to avoid multiple instances of the audio engine
    static let sharedInstance = AudioManager()

    // Create instance variables
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var booster: AKBooster!
    var silence: AKBooster!
    var tap: AKFFTTap?
    var mixer: AKMixer!


    init() {

        // Allow audio to play while the iOS device is muted.
        AKSettings.playbackWhileMuted = true

        AKSettings.defaultToSpeaker = true

        // Capture mic input
        mic = AKMicrophone()
        booster = AKBooster(mic)
        tracker = AKFrequencyTracker(booster)
        silence = AKBooster(tracker, gain: 0)
        mixer = AKMixer(silence)

        startAudioEngine()

    }

    internal func startAudioEngine() {
        AudioKit.output = mixer
        do {
            try AudioKit.start()
            print("Audio engine started")
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    internal func stopAudioEngine() {
        do {
            try AudioKit.stop()
            print("Audio engine stopped")
        } catch {
            AKLog("AudioKit did not stop!")
        }
    }
}
