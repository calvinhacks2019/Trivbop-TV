//
//  PlayerArray+PeerID.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension Array where Element: Player {
    func peerID() -> [MCPeerID] {
        var peers: [MCPeerID] = []
        self.forEach { player in
            peers.append(player.peerID)
        }
        return peers
    }

    func peerExists(peer: MCPeerID) -> Bool {
        for player in self {
            if player.peerID == peer {
                return true
            }
        }
        return false
    }
}
