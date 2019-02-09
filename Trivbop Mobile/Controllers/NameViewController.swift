//
//  ViewController.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var playButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        view.endEditing(true)
    }

    @IBAction func playButtonPressed(_ sender: Any) {
        if textField.text != nil && textField.text != "" {
            performSegue(withIdentifier: "PlaySegue", sender: nil)
        }
        textField.placeholder = "Required"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! DiscoverViewController
        destinationVC.username = textField.text!
    }
}

extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true
    }
}
