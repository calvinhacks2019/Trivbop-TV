//
//  Player.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Player {
    var peerID: MCPeerID
    var points: Int = 0
    var username: String {
        return peerID.displayName
    }

    init(peerID: MCPeerID) {
        self.peerID = peerID
    }
}
