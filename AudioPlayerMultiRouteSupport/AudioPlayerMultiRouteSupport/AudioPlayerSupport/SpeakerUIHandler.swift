//
//  SpeakerUIHandler.swift
//  MultiRouteSupport
//
//  Created by Soni Suman on 30/05/20.
//  Copyright © 2020 Soni Suman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


extension AudioOutputDeviceHandler {
    
    @objc func updateSpeakerUserInterface(screenType: ScreenType) -> UIImage {
        
        var defaultiImage  = UIImage()
        if let image = UIImage(named: "speakerOffCall") {
            defaultiImage = image
        }
        
        if AVAudioSession.sharedInstance().isBluetoothConnected {
            let imageName = getImageNameForBluetooth(screenType: screenType)
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        if AVAudioSession.sharedInstance().isBuiltInSpeaker {
            let imageName = getImageNameForSpeakerOn(screenType: screenType)
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        if AVAudioSession.sharedInstance().isBuiltInMic  || AVAudioSession.sharedInstance().isReceiver {
            let imageName = getImageNameForSpeakerOFF(screenType: screenType)
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        if  AVAudioSession.sharedInstance().isHeadphonesConnected {
            let imageName = getImageNameForHeadPhone(screenType: screenType)
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        
        if AVAudioSession.sharedInstance().isCarAudioConnected {
            let imageName = getImageNameForCarAudio(screenType: screenType)
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        return defaultiImage
    }
    
    @objc func getImageNameForBluetooth(screenType: ScreenType) -> String {
        
        var imageName = String()
        switch  screenType {
            
        case .AudioCall , .OngoingGroupCall:
            imageName = "BluetoothOnCall"
            
        case .ScreenShare ,.VideoCall :
            imageName = "VCBluetoothOn"
            
        case .NetstreamLive :
            imageName = "BluetoothOn"
            
        default:
            imageName =  "BluetoothOnCall"
        }
        return imageName
    }
    
    @objc func getImageNameForSpeakerOn(screenType: ScreenType) -> String {
        var imageName = String()
        switch  screenType {
            
        case .AudioCall , .OngoingGroupCall  :
            imageName = "speakerOnCall"
            
        case .NetstreamLive :
            imageName = "speakerOn"
            
        case .VideoCall:
            imageName = "vcSpeakerOn"
            
        case .ScreenShare:
            imageName = "speakerOffCall"
            
        default:
            imageName =  "speakerOnCall"
        }
        return imageName
    }
    
    @objc func getImageNameForSpeakerOFF(screenType: ScreenType) -> String {
        
        var imageName = String()
        switch  screenType {
            
        case .AudioCall , .OngoingGroupCall :
            imageName = "speakerOffCall"
            
        case .NetstreamLive:
            imageName = "speakerOff"
            
        case .ScreenShare:
            imageName = "speakerOnCall"
            
        case .VideoCall:
            imageName = "vcSpeakerOff"
            
        default:
            imageName =  "speakerOffCall"
        }
        return imageName
    }
    
    @objc func getImageNameForHeadPhone(screenType: ScreenType) -> String {
        var imageName = String()
        switch  screenType {
            
        case .AudioCall , .OngoingGroupCall:
            imageName = "HeadphoneOnCall"
            
        case .ScreenShare ,.VideoCall :
            imageName = "VCHeadphoneOn"
            
        case .NetstreamLive :
            imageName = "HeadphoneOn"
            
        default:
            imageName =  "HeadphoneOnCall"
        }
        return imageName
    }
    
    @objc func getImageNameForCarAudio(screenType: ScreenType) -> String {
        
        var imageName = String()
        switch  screenType {
            
        case .AudioCall , .OngoingGroupCall:
            imageName = "CarAudioOnCall"
            
        case .ScreenShare ,.VideoCall :
            imageName = "VCCarAudioOn"
            
        case .NetstreamLive :
            imageName = "CarAudioOn"
            
        default:
            imageName =  "CarAudioOnCall"
        }
        return imageName
    }
    
}

