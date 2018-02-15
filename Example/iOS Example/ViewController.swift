//
//  ViewController.swift
//  iOS Example
//
//  Created by Watanabe Toshinori on 2/14/18.
//  Copyright © 2018 Watanabe Toshinori. All rights reserved.
//

import UIKit
import GoogleHomeNotifier

class ViewController: UITableViewController {

    @IBOutlet weak var messageTextField: UITextField!

    @IBOutlet weak var languageTextField: UITextField!

    @IBOutlet weak var ipAddressTextField: UITextField!

    @IBOutlet weak var deviceNameTextField: UITextField!

    // MARK: - Actions

    @IBAction func notify(_ sender: Any) {
        view.endEditing(true)

        guard let message = messageTextField.text, message.isEmpty == false else {
            let alertController = UIAlertController(title: "Message is required.", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return
        }

        let language = languageTextField.text
        let ipAddress = ipAddressTextField.text
        let deviceName = deviceNameTextField.text

        let notifier = GoogleHomeNotifier()
        notifier.ipAddress = ipAddress
        notifier.deviceName = deviceName

        /*
           Strongly recommended using IBM Watson TTS instead of using Google TTS:
           https://www.ibm.com/watson/services/text-to-speech/
         */
        // notifier.tts = IBMTTS(username: "YOUR_USERNAME", password: "YOUR_PASSWORD")

        notifier.notify(message: message, language: language) { (error) in
            if let error = error {
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
        }
    }

}
