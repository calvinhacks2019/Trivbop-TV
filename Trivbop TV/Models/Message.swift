//
//  Message.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation

enum MessageType: Int, Codable {
    case beginGame = 0          // Prepare to recieve - to client
    case question = 1           // Client to server, my answer
    case answer = 2
    case expireQuestion = 3
    case revealResult = 4       // Right or wrong to client
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
}
