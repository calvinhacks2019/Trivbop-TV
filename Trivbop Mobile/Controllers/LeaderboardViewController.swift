//
//  LeaderboardViewController.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {

    var connection: Connectivity!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var placeLabel: UILabel!

    var me: PersonMessage? {
        didSet {
            updateMe()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity

        connection.delegate = self
    }

    func updateMe() {
        username.text = me?.username
        placeLabel.text = String(me?.lastPosition ?? 0 + 1)
    }
}

extension LeaderboardViewController: ConnectivityDelegate {
    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String]) {

    }

    func recieveMessage(type: MessageType, data: Data?) {
        OperationQueue.main.addOperation {
            switch type {
            case .showLeaderboard:
                do {
                    if let jsonString = String(data: data!, encoding: .utf8) {
                        print(jsonString)
                    }
                    let jsonDecoder = JSONDecoder()
                    let persons = try jsonDecoder.decode(PersonMessages.self, from: data!)

                    persons.persons.forEach({ player in
                        if player.username == self.connection.peerID.displayName {
                            self.me = player
                        }
                    })

                } catch {
                    let alert = UIAlertController(title: "Failed to get question", message: "\(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }

    func error(message: String) {

    }


}
