//
//  SpeechRecognizer.swift
//  SpeechRecognizerDemo
//
//  Created by Julio Collado on 4/25/20.
//  Copyright © 2020 julio. All rights reserved.
//

import Foundation
import Speech

class SpeechRecognizer {
    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    var locale: Locale
    var timer: Timer?
    
    private var isRecording = false {
        didSet {
            delegate?.isRecording(status: isRecording)
        }
    }
    
    private var isRecognizerAvailable: Bool {
        guard let speechRecognizer = speechRecognizer else {
            print("Recognizer not supported for the current location")
            return false
        }
        if !speechRecognizer.isAvailable {
            print("Recognizer is not available")
            return false
        }
        
        return true
    }
    
    var delegate: SpeechRecognizerDelegate?
    
    init(locale: Locale? = Locale(identifier: "en-US")) {
        self.locale = locale!
    }
    
    func requestUserAuthorizations() {
        requestSpeechRecognizerAuthorization()
        requestRecordPermission()
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
            return
        }
        startRecording()
    }
    
    private func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if !hasPermission {
                self.delegate?.didFailAuthorization(error: "Device recording permission was unauthorized")
            }
        }
    }
    
    private func requestSpeechRecognizerAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            guard let self = self else { return }
            switch authStatus {
            case .notDetermined:
                self.delegate?.didFailAuthorization(error: "Could not start the speech recognizer, check your internet connection and try again")
            case .denied:
                self.delegate?.didFailAuthorization(error: "Speech recognizer not allowed, enable the recognizer in Settings")
            case .restricted:
                 self.delegate?.didFailAuthorization(error: "The device prevents your app from performing speech recognition")
                break
            case .authorized:
                break
            @unknown default:
                break
            }
        }
        
    }

    private func stopRecording() {
        audioEngine?.stop()
        request?.endAudio()
        recognitionTask?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil
        isRecording = false
        timer?.invalidate()
    }
    
    private func startRecording() {
        setupRecordTimer()
        setupRecordSpeech()
        setupSpeechRecognition()
        audioEngine?.prepare()
        do {
            try audioEngine?.start()
            isRecording = true
        } catch {
            print("Turning on the AudioEngine Failed: \(error.localizedDescription)")
        }
    }
    
    private func setupRecordTimer() {
        timer = Timer(timeInterval: 5.0, target: self, selector: #selector(didEndRecordTime), userInfo: nil, repeats: false)
        if let timer = timer, timer.isValid {
           RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    @objc private func didEndRecordTime() {
        if audioEngine?.isRunning ?? false {
            stopRecording()
        }
    }
    
    private func setupRecordSpeech() {
        audioEngine = AVAudioEngine()
        let node = audioEngine?.inputNode
        let recordingFormat = node?.outputFormat(forBus: 0)
        node?.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request?.append(buffer)
        }
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        request = SFSpeechAudioBufferRecognitionRequest()
        guard isRecognizerAvailable, let request = request else { return }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { [ weak self] (result, error) in
            guard let self = self else { return }
            if let result = result {
                self.delegate?.didRecognize(text: result.bestTranscription.formattedString)
            } else if let error = error {
                print("Recognition Error: \(error.localizedDescription)")
            }
        })
    }
}
