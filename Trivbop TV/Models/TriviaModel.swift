//
//  TriviaModel.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation

struct TriviaModel: Codable {
    let responseCode: ResponseCode
    let results: [Question]?
    var currentIndex: Int = -1

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }

    mutating func getNext() -> Question? {
        guard let questions = results,
            questions.indices.contains(currentIndex + 1) else { return nil }
        currentIndex += 1
        let question = questions[currentIndex]
        return question
    }

    func getCurrent() -> Question? {
        guard let questions = results,
            questions.indices.contains(currentIndex) else { return nil }

        return questions[currentIndex]
    }


    init() {
        responseCode = .noResult
        results = nil
    }
}

class Question: Codable {
    let category: String
    let type: QuestionType
    let difficulty: Difficulty
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    lazy var shuffledAnswers: [String] = {
        switch self.type {
        case .boolean:
            return ["True", "False"]
        case .multiple:
            var answers = self.incorrectAnswers
            answers.append(correctAnswer)
            answers.shuffle()
            return answers
        }
    }()

    enum CodingKeys: String, CodingKey {
        case category
        case type
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum Difficulty: String, Codable {
    case easy
    case hard
    case medium
}

enum QuestionType: String, Codable {
    case boolean
    case multiple
}

enum ResponseCode: Int, Codable {
    case success = 0
    case noResult = 1
    case invalidParmeter = 2
    case tokenNotFound = 3
    case tokenEmpty = 4
}

