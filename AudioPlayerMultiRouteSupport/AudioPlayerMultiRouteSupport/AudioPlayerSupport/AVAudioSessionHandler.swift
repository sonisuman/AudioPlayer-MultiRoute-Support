//
//  AVAudioSessionHandler.swift
//  MultiRouteSupport
//
//  Created by Soni Suman on 30/05/20.
//  Copyright © 2020 Soni Suman. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension AVAudioSession {
    
    @objc func ChangeAudioOutput(_ presenterViewController : UIViewController, _ speakerButton: UIButton) {
        
        let CHECKED_KEY = "checked"
        var deviceAction = UIAlertAction()
        var headphonesExist = false
        
        if AudioOutputDeviceHandler.sharedInstance.isDeviceListRequired() {
            
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            for audioPort in self.availableInputs!{
                
                switch audioPort.portType {
                    
                case AVAudioSession.Port.bluetoothA2DP, AVAudioSession.Port.bluetoothHFP, AVAudioSession.Port.bluetoothLE :
                    
                    overrideBluetooth(audioPort, optionMenu)
                    break
                    
                case AVAudioSession.Port.builtInMic, AVAudioSession.Port.builtInReceiver:
                    
                    deviceAction = overrideBuiltInReceiver(audioPort)
                    break
                    
                case AVAudioSession.Port.headphones, AVAudioSession.Port.headsetMic:
                    
                    headphonesExist = true
                    overrideheadphones(audioPort,optionMenu)
                    break
                    
                case AVAudioSession.Port.carAudio:
                    overrideCarAudio(port: audioPort, optionMenu: optionMenu)
                    break
                    
                default:
                    break
                }
            }
            
            if !headphonesExist {
                
                if self.currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.builtInReceiver}) || self.currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.builtInMic}) {
                    deviceAction.setValue(true, forKey: CHECKED_KEY)
                }
                optionMenu.addAction(deviceAction)
            }
            
            overrideSpeaker(optionMenu)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            
            optionMenu.addAction(cancelAction)
            
            alertViewSetupForIpad(optionMenu, speakerButton)
            presenterViewController.present(optionMenu, animated: false, completion: nil)
            
            // auto dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                optionMenu.dismiss(animated: true, completion: nil)
            }
            
        } else {
            if self.isBuiltInSpeaker {
                
                if AudioOutputDeviceHandler.sharedInstance.isSpeaker {
                    let port = self.currentRoute.inputs.first!
                    setPortToNone(port)
                    AudioOutputDeviceHandler.sharedInstance.isSpeaker = false
                }
            }
            else if self.isReceiver || self.isBuiltInMic  || self.isHeadphonesConnected {
                
                setPortToSpeaker()
                AudioOutputDeviceHandler.sharedInstance.isSpeaker = true
            }
        }
    }
    
    func overrideCarAudio(port: AVAudioSessionPortDescription, optionMenu: UIAlertController) {
        
        let action = UIAlertAction(title: port.portName, style: .default) { (action) in
            do {
                // set new input
                try self.setPreferredInput(port)
            } catch let error as NSError {
                print("audioSession error change to input: \(port.portName) with error: \(error.localizedDescription)")
            }
        }
        
        if self.currentRoute.outputs.contains(where: {return $0.portType == port.portType}){
            action.setValue(true, forKey: "checked")
        }
        
        if let image = UIImage(named: "CarAudio") {
            action.setValue(image, forKey: "image")
        }
        optionMenu.addAction(action)
    }
    
    func overrideheadphones(_ port: AVAudioSessionPortDescription, _ optionMenu: UIAlertController) {
        
        let CHECKED_KEY = "checked"
        let HEADPHONES_TITLE = "Headphones"
        let action = UIAlertAction(title: HEADPHONES_TITLE, style: .default) { (action) in
            do {
                // set new input
                try self.setPreferredInput(port)
            } catch let error as NSError {
                print("audioSession error change to input: \(port.portName) with error: \(error.localizedDescription)")
            }
        }
        
        if self.currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.headphones}) || self.currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.headsetMic}) {
            action.setValue(true, forKey: CHECKED_KEY)
        }
        
        if let image = UIImage(named: "Headphone") {
            action.setValue(image, forKey: "image")
        }
        
        optionMenu.addAction(action)
    }
    
    func overrideSpeaker(_ optionMenu: UIAlertController) {
        
        let SPEAKER_TITLE = "Speaker"
        let CHECKED_KEY = "checked"
        let speakerOutput = UIAlertAction(title: SPEAKER_TITLE, style: .default, handler: {
            [weak self] (alert: UIAlertAction!) -> Void in
            self?.setPortToSpeaker()
        })
        AudioOutputDeviceHandler.sharedInstance.isSpeaker = true
        
        if self.currentRoute.outputs.contains(where: {return $0.portType == AVAudioSession.Port.builtInSpeaker}){
            
            speakerOutput.setValue(true, forKey: CHECKED_KEY)
        }
        
        if let image = UIImage(named: "Speaker") {
            speakerOutput.setValue(image, forKey: "image")
        }
        optionMenu.addAction(speakerOutput)
    }
    
    func overrideBluetooth(_ port: AVAudioSessionPortDescription, _ optionMenu: UIAlertController) {
        
        let CHECKED_KEY = "checked"
        let action = UIAlertAction(title: port.portName, style: .default) { (action) in
            do {
                // set new input
                try self.setPreferredInput(port)
            } catch let error as NSError {
                print("audioSession error change to input: \(port.portName) with error: \(error.localizedDescription)")
            }
        }
        
        if self.currentRoute.outputs.contains(where: {return $0.portType == port.portType}){
            action.setValue(true, forKey: CHECKED_KEY)
        }
        if let image = UIImage(named: "Bluetooth") {
            action.setValue(image, forKey: "image")
        }
        optionMenu.addAction(action)
    }
    
    func overrideBuiltInReceiver(_ port: AVAudioSessionPortDescription) -> UIAlertAction {
        
        let IPHONE_TITLE = "iPhone"
        let deviceAction = UIAlertAction(title: IPHONE_TITLE, style: .default) {[weak self] (action) in
            self?.setPortToNone(port)
        }
        
        if let image = UIImage(named: "Device") {
            deviceAction.setValue(image, forKey: "image")
        }
        return deviceAction
    }
    
    func setPortToSpeaker() {
        
        do {
            try self.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error turning on speaker: \(error.localizedDescription)")
        }
    }
    
    func setPortToNone(_ port: AVAudioSessionPortDescription) {
        
        do {
            // remove speaker if needed
            try self.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            // set new input
            try self.setPreferredInput(port)
        } catch let error as NSError {
            print("audioSession error change to input: \(AVAudioSession.PortOverride.none.rawValue) with error: \(error.localizedDescription)")
        }
    }
    
    func alertViewSetupForIpad(_ optionMenu: UIAlertController, _ speakerButton: UIButton) {
        optionMenu.modalPresentationStyle = .popover
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = speakerButton;
            presenter.sourceRect = speakerButton.bounds;
        }
    }
}

extension AVAudioSession {
    
    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }
    
    static var isBluetoothConnected: Bool {
        return sharedInstance().isBluetoothConnected
    }
    
    static var isCarAudioConnected: Bool {
        return sharedInstance().isCarAudioConnected
    }
    
    static var isBuiltInSpeaker: Bool {
        return sharedInstance().isBuiltInSpeaker
    }
    
    static var isReceiver: Bool {
        return sharedInstance().isReceiver
    }
    
    static var isBuiltInMic: Bool {
        return sharedInstance().isBuiltInMic
    }
    
    var isCarAudioConnected: Bool {
        return !currentRoute.outputs.filter { $0.isCarAudio }.isEmpty
    }
    
    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
    
    var isBluetoothConnected: Bool {
        return !currentRoute.outputs.filter { $0.isBluetooth }.isEmpty
    }
    
    var isBuiltInSpeaker: Bool {
        return !currentRoute.outputs.filter { $0.isSpeaker }.isEmpty
    }
    
    var isReceiver: Bool {
        return !currentRoute.outputs.filter { $0.isReceiver }.isEmpty
    }
    
    var isBuiltInMic: Bool {
        return !currentRoute.outputs.filter { $0.isBuiltInMic }.isEmpty
    }
}

extension AVAudioSessionPortDescription {
    
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones  ||  portType == AVAudioSession.Port.headsetMic
    }
    
    var isBluetooth: Bool {
        return portType == AVAudioSession.Port.bluetoothHFP || portType == AVAudioSession.Port.bluetoothA2DP || portType == AVAudioSession.Port.bluetoothLE
    }
    
    var isCarAudio: Bool {
        return portType == AVAudioSession.Port.carAudio
    }
    
    var isSpeaker: Bool {
        return portType == AVAudioSession.Port.builtInSpeaker
    }
    
    var isBuiltInMic: Bool {
        return portType == AVAudioSession.Port.builtInMic
    }
    
    var isReceiver: Bool {
        return portType == AVAudioSession.Port.builtInReceiver
    }
}
