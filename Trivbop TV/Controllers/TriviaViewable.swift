//
//  TriviaViewable.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation

protocol TriviaViewable {
    func loadTrivia(model: TriviaModel)
    func showError()
}
