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
    func readItem(readableItem: Readable)
    func readItemWithoutStop(prefixText: String, readableItem: Readable)
    func readItem(prefixText: String, readableItem: Readable)
    func stopIfNeeded()
    func reReadCurrent()
    func setReadingCallback(delegate: ReadingCallbackDelegate)
    var readingCallbackDelegate: ReadingCallbackDelegate? { get set }
}

protocol ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange)
}

class ReadHandler: NSObject {

    var synthesizer = AVSpeechSynthesizer()
    var speakBody: (() -> Void)?
    var state: ReadState = .stopped {
        didSet {
            if state == .finished {
                currentRead?.readCompletionHandler?()
            }
        }
    }
    var currentRead: Readable?
    var prefixText: String?
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
        self.prefixText = prefix
        
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
    
    func readItemWithoutStop(prefixText: String, readableItem: Readable) {
        self.currentRead = readableItem
        speak(prefix: prefixText, body: readableItem.text)
    }

    func setReadingCallback(delegate: ReadingCallbackDelegate) {
        readingCallbackDelegate = delegate
    }
    
    func reReadCurrent() {
        if let currentRead = currentRead {
            readItem(prefixText: "", readableItem: currentRead)
        }
    }

    func readItem(readableItem: Readable) {
        stopIfNeeded()
        speak(text: readableItem.text)
    }
    
    func readItem(prefixText: String, readableItem: Readable) {
        stopIfNeeded()
        readItemWithoutStop(prefixText: prefixText, readableItem: readableItem)
    }
    
    func stopIfNeeded() {
        currentRead?.readCompletionHandler = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension ReadHandler: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let prefixText = prefixText, utterance.speechString != prefixText else {
            return
        }
        
        if let speakBody = speakBody, state == .readingPrefix {
            speakBody()
        }
        
        state = .finished
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        state = .stopped
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        guard let prefixText = prefixText, utterance.speechString != prefixText else {
            return
        }
        
        readingCallbackDelegate?.willSpeak(utterance.speechString, characterRange: characterRange)
    }
}
