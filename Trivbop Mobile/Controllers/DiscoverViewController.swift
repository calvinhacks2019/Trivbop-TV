//
//  DiscoverViewController.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    var connection: Connectivity!

    @IBOutlet weak var searchingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectionLabel: UILabel!

    var username: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity

        connection.setupPeerWithDisplayName(displayName: username)
        connection.setupSession()
        connection.advertiseSelf(advertise: true)
        connection.delegate = self

        activityIndicator.startAnimating()
    }
}

extension DiscoverViewController: ConnectivityDelegate {
    func error(message: String) {
        // TODO
        print(message)
    }

    func recieveMessage(type: MessageType, data: Data?) {
        OperationQueue.main.addOperation {
            switch type {
            case .beginGame:
                print("begin game message recieved")
                self.performSegue(withIdentifier: "StartGameSegue", sender: nil)
            default:
                break
            }
        }
    }

    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            guard connectedDevices.count > 0 else { return }

            self.activityIndicator.stopAnimating()
            self.searchingView.isHidden = true
            self.connectionLabel.isHidden = false
            self.connectionLabel.text = "Connected to \(connectedDevices[0])"
        }
    }
}
