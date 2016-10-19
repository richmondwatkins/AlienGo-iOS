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
    case reading, stopped, finished, notStarted
}

typealias ReaderCompletion = (() -> Void)?

protocol ReadableDelegate {
    func stop()
    func hardStop()
    func reReadCurrent()
    func readItem(readableItem: Readable, delegate: ReadingCallbackDelegate?, completion: ReaderCompletion)
}

protocol ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange)
}

class ReadHandler: NSObject {

    static let shared: ReadHandler = ReadHandler()
    var synthesizer = AVSpeechSynthesizer()
    var state: ReadState = .notStarted
    var currentRead: Readable?
    var readingCallbackDelegate: ReadingCallbackDelegate? {
        didSet {
            synthesizer.delegate = self
        }
    }
    var completion: ReaderCompletion
    var startNew: (() -> Void)?
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak(text: String) {
        let utterance = self.createUtterance(text: text)
        
        self.synthesizer.speak(utterance)
        
        self.state = .reading
    }
    
    private func createUtterance(text: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        return utterance
    }
}

extension ReadHandler: ReadableDelegate {

    func readItem(readableItem: Readable, delegate: ReadingCallbackDelegate?, completion: ReaderCompletion) {
        
        startNew = {
            self.state = .reading
            
            self.synthesizer.delegate = nil
            
            let words = readableItem.text.words()
            var originalText = readableItem.text
            var urls: [String] = []
            
            words.forEach { (word) in
                if word.isURL() {
                    urls.append(word)
                }
            }
            
            urls.forEach { (url) in
                originalText = originalText.replacingOccurrences(of: url, with: " skipping un readable u r l ")
            }
            
            self.readingCallbackDelegate = delegate
            self.completion = completion
            self.readItem(readableItem: ReaderContainer(text: originalText))
            self.startNew = nil
        }
        
        if synthesizer.isSpeaking || state == .reading {
           
        } else {
            
        }
        
        hardStop()
        startNew?()
    }
    
    func reReadCurrent() {
        if let currentRead = currentRead {
            readItem(readableItem: currentRead)
        }
    }

    func readItem(readableItem: Readable) {
        speak(text: readableItem.text)
    }
    
    
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            hardStop()
        }
    }
    
    func hardStop() {
        synthesizer.stopSpeaking(at: .immediate)
        currentRead = nil
        completion = nil
    }
}

extension ReadHandler: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completion?()
        startNew?()
        state = .finished
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        completion?()
        state = .stopped
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        readingCallbackDelegate?.willSpeak(utterance.speechString, characterRange: characterRange)
    }
}
