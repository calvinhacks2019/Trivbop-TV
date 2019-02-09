//
//  Message.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

enum MessageType: Int, Codable {
    case beginGame = 0          // Prepare to recieve - to client
    case question = 1           // Client to server, my answer
    case answer = 2
    case expireQuestion = 3
    case revealResult = 4       // Right or wrong to client
    case showLeaderboard = 5
}

struct MessageSendable: Codable {
    var type: MessageType
    var data: Data?

    init(type: MessageType) {
        self.type = type
    }
}

struct Answer: Codable {
    var answer: String
    var timeElapsed: Double
    var isCorrect: Bool

    init(answer: String, time: Double, isCorrect: Bool) {
        self.answer = answer
        self.timeElapsed = time
        self.isCorrect = isCorrect
    }
}


struct PersonMessage: Codable {
    var points: Int
    var colorIndex: Int
    var lastPosition: Int
    var username: String
}

struct PersonMessages: Codable {
    static let color = [#colorLiteral(red: 0.9989669919, green: 0.9400753379, blue: 0.000275353028, alpha: 1), #colorLiteral(red: 0.9688273072, green: 0.5396862626, blue: 0.03644859791, alpha: 1), #colorLiteral(red: 0.910797596, green: 0.01392253675, blue: 0.1019292399, alpha: 1), #colorLiteral(red: 0.007182718255, green: 0.3697192073, blue: 0.6769234538, alpha: 1), #colorLiteral(red: 0.606991291, green: 0.5868093967, blue: 0.9387260675, alpha: 1), #colorLiteral(red: 0.310677588, green: 0.6920595765, blue: 0.2366237044, alpha: 1)]

    var persons = [PersonMessage]()
}
