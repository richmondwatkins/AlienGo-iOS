//
//  ReadHandler.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import AVFoundation

enum ReadState {
    case readingPrefix, readingBody, stopped, finished
}

protocol ReadableDelegate {
    func readItem(prefixText: String, readableItem: Readable)
    func stopIfNeeded()
    func setReadingCallback(delegate: ReadingCallbackDelegate)
    var readingCallbackDelegate: ReadingCallbackDelegate? { get set }
}

protocol ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange)
}

class ReadHandler: NSObject {

    var synthesizer = AVSpeechSynthesizer()
    var speakBody: (() -> Void)?
    var state: ReadState = .stopped
    var previousRead: Readable?
    var readingCallbackDelegate: ReadingCallbackDelegate?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String) {
        let speak = {
            let utterance = self.createUtterance(text: text)
            
            self.synthesizer.speak(utterance)
            
            self.state = .readingBody
        }
        
        if state == .readingPrefix {
            speak()
        } else {
            speakBody = speak
        }
    }
    
    func speak(prefix: String, body: String) {
        
        let prefixUtterance = createUtterance(text: prefix)
        
        self.synthesizer.speak(prefixUtterance)
        
        state = .readingPrefix
        
        self.speak(text: body)
    }
    
    private func createUtterance(text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        return utterance
    }
}

extension ReadHandler: ReadableDelegate {

    func setReadingCallback(delegate: ReadingCallbackDelegate) {
        readingCallbackDelegate = delegate
    }
    
    func readItem(prefixText: String, readableItem: Readable) {
        stopIfNeeded()
        speak(prefix: prefixText, body: readableItem.text)
    }
    
    func stopIfNeeded() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension ReadHandler: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let speakBody = speakBody, state == .readingPrefix {
            speakBody()
        }
        
        state = .finished
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        readingCallbackDelegate?.willSpeak(utterance.speechString, characterRange: characterRange)
    }
}
