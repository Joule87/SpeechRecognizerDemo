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
    var recordButton: UIBarButtonItem!
    
    var isRecording = false
    private let pulsingLayerName = "pulsingLayer"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupSearchBar()
        setupRecordButton()
    }
    
    func setupSearchBar() {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    func setupRecordButton() {
        recordButton = UIBarButtonItem(image: #imageLiteral(resourceName: "micro"), style: .done, target: self, action: #selector(didTapRecordButton))
        recordButton.tintColor = .black
        navigationItem.rightBarButtonItem = recordButton
    }
    
    @objc func didTapRecordButton() {
        isRecording ? stopRecordingButtonAnimation() : startRecordingButtonAnimation()
        isRecording = !isRecording
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

}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resultLabel.text = searchBar.text
        searchBar.resignFirstResponder()
    }
    
    
}

