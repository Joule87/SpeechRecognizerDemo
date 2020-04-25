//
//  SpeechRecognizerDelegate.swift
//  SpeechRecognizerDemo
//
//  Created by Julio Collado on 4/25/20.
//  Copyright © 2020 julio. All rights reserved.
//

import Foundation

protocol SpeechRecognizerDelegate {
    func didRecognize(text: String)
    func didFailAuthorization(error: String)
    func isRecording(status: Bool)
}
