//
//  ReadHandler.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import AVFoundation

protocol Readable {
    var text: String { get }
}

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

typealias Utterance = String

class ReadHandler: NSObject {

    static let shared: ReadHandler = ReadHandler()
    var synthesizer = AVSpeechSynthesizer()
    var state: ReadState = .notStarted
    var currentRead: Readable?
    var queue: [Utterance: (completion: ReaderCompletion, callback: ReadingCallbackDelegate?)] = [:]
    var readingCallbackDelegate: ReadingCallbackDelegate? {
        didSet {
            synthesizer.delegate = self
        }
    }
    var completion: ReaderCompletion
    var startNew: (() -> Void)?
    var canceled: Bool = false
    
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
        utterance.rate = UserInfo.utteranceSpeed 
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        return utterance
    }
}

extension ReadHandler: ReadableDelegate {

    func readItem(readableItem: Readable, delegate: ReadingCallbackDelegate?, completion: ReaderCompletion) {
    
        DispatchQueue.main.async { [weak self] in
            self?.startNew = {
                DispatchQueue.main.async { [weak self] in
                    self?.state = .reading
                    
                    self?.synthesizer.delegate = nil
                    
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
                    
                    self?.queue[originalText] = (completion, delegate)
                    
                    self?.readingCallbackDelegate = delegate
                    self?.completion = completion
                    self?.readItem(readableItem: ReaderContainer(text: originalText))
                    self?.startNew = nil
                }
            }
            
            if self!.queue.isEmpty || !self!.synthesizer.isSpeaking {
                self?.startNew?()
            } else {
                self?.hardStop()
            }
        }
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
        if synthesizer.isSpeaking {
            canceled = true
        }
        
        readingCallbackDelegate = nil
        currentRead = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension ReadHandler: AVSpeechSynthesizerDelegate {

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [unowned self] in
            self.readingCallbackDelegate = nil
            if let completion = self.queue[utterance.speechString]?.completion, !self.canceled {
                completion()
                self.queue.removeValue(forKey: utterance.speechString)
            }
            
            self.canceled = false
            self.state = .finished
            print(self.startNew)
            self.startNew?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [unowned self] in
            self.readingCallbackDelegate = nil
            if let completion = self.queue[utterance.speechString]?.completion, !self.canceled {
                completion()
                self.queue.removeValue(forKey: utterance.speechString)
            }
            
            self.canceled = false
            self.state = .finished
            print(self.startNew)
            self.startNew?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        if let delegate = queue[utterance.speechString]?.callback {
            delegate.willSpeak(utterance.speechString, characterRange: characterRange)
        }
    }
}
