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
    case questionSingle = 1
    case questionAll = 2
    case questionDual = 3       // Question to client
    case questionAnswer = 4     // Client to server, my answer
    case questionResult = 5     // Right or wrong to client
}

protocol Message: Codable {
    var type: MessageType { get set }
}

struct MessageSendable: Codable {
    var type: MessageType
    var data: Data?

    init(type: MessageType) {
        self.type = type
    }
}

struct StartMessage: Message, Codable {
    var type: MessageType = .beginGame
}

struct AllQuestionMessage: Message, Codable {
    var type: MessageType = .questionAll
    var question: Question

    init(question: Question) {
        self.question = question
    }
}
