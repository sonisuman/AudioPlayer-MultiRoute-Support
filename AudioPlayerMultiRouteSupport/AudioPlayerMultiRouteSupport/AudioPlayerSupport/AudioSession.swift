//
//  AudioSession.swift
//  MultiRouteSupport
//
//  Created by Soni Suman on 30/05/20.
//  Copyright © 2020 Soni Suman. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioSessionHandler {
    var headphonesConnected = false
    
    func audioSessionSetup() {

        // Access the shared, singleton audio session instance
        let session = AVAudioSession.sharedInstance()
        do {
            // Configure the audio session for playAndRecord
            try session.setCategory(AVAudioSession.Category.playAndRecord,
                                    mode: AVAudioSession.Mode.videoChat,
                                    options: [])
            try session.setActive(true)
            } catch let error as NSError {
                print("Failed to set the audio session category and mode: \(error.localizedDescription)")
            }
        
            // Set preferred sample rate
            do {
                try session.setPreferredSampleRate(44_100)
            } catch let error as NSError {
                print("Unable to set preferred sample rate:  \(error.localizedDescription)")
            }
             
            // Set preferred I/O buffer duration
            do {
                try session.setPreferredIOBufferDuration(0.005)
            } catch let error as NSError {
                print("Unable to set preferred I/O buffer duration:  \(error.localizedDescription)")
            }
             
            // Activate the audio session
            do {
                try session.setActive(true)
            } catch let error as NSError {
                print("Unable to activate session. \(error.localizedDescription)")
            }
             
            // Query the audio session's ioBufferDuration and sampleRate properties
            // to determine if the preferred values were set
            print("Audio Session ioBufferDuration: \(session.ioBufferDuration), sampleRate: \(session.sampleRate)")
        
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSecondaryAudio),
                                               name: AVAudioSession.silenceSecondaryAudioHintNotification,
                                               object: AVAudioSession.sharedInstance())
           NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleInterruption),
                                                   name: AVAudioSession.interruptionNotification,
                                                   object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self,
        selector: #selector(handleRouteChange),
        name: AVAudioSession.routeChangeNotification,
        object: AVAudioSession.sharedInstance())
         
        
    }
 @objc   func handleRouteChange(_ notification: Notification) {
       guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
        let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                headphonesConnected = true
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    headphonesConnected = false
                }
            }
        default: ()
        }
    }
     
    @objc func handleSecondaryAudio(notification: Notification) {
        // Determine hint type
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
            let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
                return
        }
     
        if type == .begin {
            // Other app audio started playing - mute secondary audio
        } else {
            // Other app audio stopped playing - restart secondary audio
        }
    }
    @objc func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }
            if type == .began {
                // Interruption began, take appropriate actions (save state, update user interface)
            }
            else if type == .ended {
                guard let optionsValue =
                    info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                        return
                }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                }
            }
        }
}




