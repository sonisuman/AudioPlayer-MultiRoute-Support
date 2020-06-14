//
//  AudioOutputDeviceHandler.swift
//  MultiRouteSupport
//
//  Created by Soni Suman on 30/05/20.
//  Copyright © 2020 Soni Suman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc enum AudioRoute: Int {
    /* Headphone or headset output */
    case Headphones
    /* Built-in speaker on an iOS device */
    case Speaker
    /*  Input or output on a Bluetooth Hands-Free Profile device */
    case Bluetooth
    /* Input or output via Car Audio */
    case CarAudio
    case Receiver
    case None
}

@objc enum ScreenType: Int {
    
    case OngoingGroupCall
    case AudioCall
    case ScreenShare
    case VideoCall
    case NetstreamLive
    
}

//Setting Preferred Audio Hardware Values
@objc class AudioOutputDeviceHandler: NSObject {
    @objc static let sharedInstance = AudioOutputDeviceHandler()
    var isSpeaker = false
    private override init() {
        super.init()
    }
    
    @objc  func getCurrentPortType() -> AVAudioSession.Port.RawValue? {
        let session = AVAudioSession.sharedInstance()
        
        if let portDescription =  session.currentRoute.outputs.first {
            return portDescription.portType.rawValue
        }
        return nil
    }
    
    @objc func getCurrentAudioRoute () -> AudioRoute {
        let session = AVAudioSession.sharedInstance()
        guard   let portDiscription = session.currentRoute.outputs.first else {return .None}
        if portDiscription.portType  == .builtInSpeaker {
            return .Speaker
        }
        if portDiscription.portType  == .bluetoothA2DP || portDiscription.portType  == .bluetoothLE || portDiscription.portType  == .bluetoothHFP {
            return .Bluetooth
        }
        if portDiscription.portType  == .headsetMic ||  portDiscription.portType == .headphones || portDiscription.portType == .builtInMic {
            return .Headphones
        }
        if portDiscription.portType == .builtInReceiver {
            return .Receiver
        }
        if portDiscription.portType  == .carAudio {
            return .CarAudio
        }
        return .None
    }
    
    @objc func isHeadPhoneAvailable() -> Bool {
        guard let availableInputs = AVAudioSession.sharedInstance().availableInputs else {return false}
        for inputDevice in availableInputs {
            if inputDevice.portType == .headsetMic  || inputDevice.portType == .headphones {
                return true
            }
        }
        return false
    }
    @objc func isInbuiltMicAvailable() -> Bool {
        guard let availableInputs = AVAudioSession.sharedInstance().availableInputs else {return false}
        for inputDevice in availableInputs {
            if inputDevice.portType == .builtInReceiver  || inputDevice.portType == .builtInMic {
                return true
            }
        }
        return false
    }
    
    @objc func isDeviceListRequired()-> Bool {
        guard let deviceList = AVAudioSession.sharedInstance().availableInputs else { return false }
        
        if deviceList.count == 2  {
            if isHeadPhoneAvailable() {
                if isInbuiltMicAvailable() {
                    return false
                }
            } else {
                return true
            }
        } else if deviceList.count == 1 {
            
            if !isHeadPhoneAvailable() && !isInbuiltMicAvailable() {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
        return false
    }
    
    @objc func listOfAvailableDevices(controller:UIViewController,speakerButton: UIButton)  {
        AVAudioSession.sharedInstance().ChangeAudioOutput(controller, speakerButton)
    }
    
    @objc func forceOutputPortToSpeaker() {
        
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error turning on speaker: \(error.localizedDescription)")
        }
        isSpeaker = true
    }
}



