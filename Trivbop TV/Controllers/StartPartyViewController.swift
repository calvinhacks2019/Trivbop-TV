//
//  StartPartyViewController.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class StartPartyViewController: UIViewController {
    var connection: Connectivity!

    var connectedDevices: [String]?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity

        connection.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        connection.setupSession()
        connection.setupBrowser()
        connection.advertiseSelf(advertise: true)
        connection.browseSelf(browse: true)
        connection.delegate = self

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }

    @IBAction func playButton(_ sender: Any) {
        guard let data = encode() else  {
            print("Failed to encode")
            return
        }
        connection.sendData(data: data, to: nil)
    }

    func encode() -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let message = MessageSendable(type: .beginGame)
            let jsonData = try jsonEncoder.encode(message)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }

            return jsonData
        } catch {
            let alert = UIAlertController(title: "Failed to encode", message: "We could not send message to one or more device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        return nil
    }
}

extension StartPartyViewController: ConnectivityDelegate {
    func error(_: String) {
        let alert = UIAlertController(title: "Failed to encode", message: "We could not send message to one or more device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func recieveMessage(type: MessageType, data: Any) {
        // TODO
    }

    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectedDevices = connectedDevices
            self.tableView.reloadData()
        }
    }
}

extension StartPartyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedDevices?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell")!
        let device = connectedDevices![indexPath.row]
        cell.textLabel?.text = device
        return cell
    }
}

extension StartPartyViewController: UITableViewDelegate {

}
