//
//  ViewController.swift
//  SpeechRecognizerDemo
//
//  Created by Julio Collado on 4/24/20.
//  Copyright © 2020 julio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var selectedLanguageLabel: UILabel!
    
    var recordButton: UIBarButtonItem!
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    private let pulsingLayerName = "pulsingLayer"
    lazy var currentRecordLanguage: String = {
        let code = speechRecognizer.locale.languageCode ?? ""
        let language = speechRecognizer.locale.localizedString(forLanguageCode: code)
        return language ?? "English"
    }()
    
    private var speechRecognizer = SpeechRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchBar()
        setupRecordButton()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer.delegate = self
        speechRecognizer.requestUserAuthorizations()
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func setupRecordButton() {
        recordButton = UIBarButtonItem(image: #imageLiteral(resourceName: "micro"), style: .done, target: self, action: #selector(didTapRecordButton))
        recordButton.tintColor = .black
        navigationItem.rightBarButtonItem = recordButton
    }
    
    @objc func didTapRecordButton() {
        speechRecognizer.toggleRecording()
    }
    
    func stopRecordingButtonAnimation() {
        navigationController?.view.layer.sublayers?.removeAll{ $0.name == pulsingLayerName}
        recordButton.tintColor = .black
    }
    
    func startRecordingButtonAnimation() {
        guard let buttonView = recordButton.value(forKey: "view") as? UIView,
            let position = buttonView.superview?.convert(buttonView.center, to: nil) else { return }
        recordButton.tintColor = .red
        let radius = buttonView.frame.size.height * 0.60
        let pulse = Pulsing(radius: radius, position: position)
        pulse.name = pulsingLayerName
        pulse.animationDuration = 0.8
        pulse.backgroundColor = UIColor.red.cgColor
        navigationController?.view.layer.insertSublayer(pulse, above: buttonView.layer)
    }
    
    @IBAction func didTapChangeSearchLanguage(_ sender: UIButton) {
        // Create AlertController
        let alert = AlertController(title: "Change Language", message: "Choose a given language to use on speech recognition functionality. If you don't the app will use English as default language.", preferredStyle: .alert)
        alert.setTitleImage(UIImage(named: "alert"))
        // Add actions
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        action.actionImage = UIImage(named: "close")
        let englishAction = UIAlertAction(title: "English", style: .default, handler: { (_) in
            self.updateLocale(for: "en-US")
        })
        alert.addAction(action)
        
        let spanishAction = UIAlertAction(title: "Spanish", style: .destructive, handler: { (_) in
            self.updateLocale(for: "es")
        })
        alert.addAction(englishAction)
        alert.addAction(spanishAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateLocale(for identifier: String) {
        speechRecognizer.locale = Locale(identifier: identifier)
        selectedLanguageLabel.text = "Selected language: \(currentRecordLanguage)"
    }
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchValue = searchBar.text, !searchValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        ///This is just for simulating a network call or a database search
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.resultLabel.text = "Items found for search: \(searchValue)"
        }
        searchBar.resignFirstResponder()
    }
    
}

extension ViewController: SpeechRecognizerDelegate {
    func didRecognize(text: String) {
        searchBar.text = text
        self.searchBarSearchButtonClicked(searchBar)
    }
    
    func didFailAuthorization(error: String) {
        print("Error: \(error)")
    }
    
    func isRecording(status: Bool) {
        status ? startRecordingButtonAnimation() : stopRecordingButtonAnimation()
    }
    
    
}
