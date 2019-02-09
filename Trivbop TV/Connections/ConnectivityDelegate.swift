//
//  ConnectivityDelegate.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ConnectivityDelegate {
    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String])
    func recieveMessage(type: MessageType, data: Data?, from peer: MCPeerID)
    func error(message: String)
}
