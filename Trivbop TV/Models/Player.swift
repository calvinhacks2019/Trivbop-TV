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
    static var colorPool: [UIColor] = [#colorLiteral(red: 0.9989669919, green: 0.9400753379, blue: 0.000275353028, alpha: 1), #colorLiteral(red: 0.9688273072, green: 0.5396862626, blue: 0.03644859791, alpha: 1), #colorLiteral(red: 0.910797596, green: 0.01392253675, blue: 0.1019292399, alpha: 1), #colorLiteral(red: 0.007182718255, green: 0.3697192073, blue: 0.6769234538, alpha: 1), #colorLiteral(red: 0.606991291, green: 0.5868093967, blue: 0.9387260675, alpha: 1), #colorLiteral(red: 0.310677588, green: 0.6920595765, blue: 0.2366237044, alpha: 1)]

    var peerID: MCPeerID
    var points: Int = 0
    var username: String {
        return peerID.displayName
    }
    var color: UIColor
    var lastPosition: Int?

    init(peerID: MCPeerID) {
        self.peerID = peerID

        if Player.colorPool.indices.contains(0) {
            self.color = Player.colorPool[0]
            Player.colorPool.remove(at: 0)
        } else {
            self.color = UIColor.red
        }
    }

    func addPoint(timeElapsed: Double) {
        print("Time: \(timeElapsed)")
        print(timeElapsed)
        if timeElapsed <= 4.4 {
            points += 1000
        } else {
            points += Int(1000 - 700 * (1.0 / 5.6 * (timeElapsed - 4.4)))
        }
        print("Gave \(username) \(points)")
    }
}
