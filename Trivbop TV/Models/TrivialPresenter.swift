//
//  TrivialPresenter.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation

class TriviaPresenter {
    var view: TriviaViewable!

    private let base = "https://opentdb.com/api.php"
    private let tokenBase = "https://opentdb.com/api_token.php"
    private var token: String?
    private var url: URL?

    init(view: TriviaViewable) {
        self.view = view
    }

    func generateToken() {
        guard var urlComponents = URLComponents(string: tokenBase) else {
            fatalError("Failed to get base url")
        }
        let quertyItem = URLQueryItem(name: "command", value: "request")
        urlComponents.queryItems = [quertyItem]

        guard let url = urlComponents.url else {
            fatalError("Could not build token url")
        }
        print(url)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
                guard let jsonArray = jsonResponse as? [String: Any],
                    let token = jsonArray["token"] as? String else {
                    print("Bad token response parse")
                    return
                }
                self.token = token
            } catch {
                print("Error", error)
            }
        }
        task.resume()
    }

    private func getFullURL(amount: Int) -> URL? {
        guard var urlComponents = URLComponents(string: base) else { return nil }
        let queryItems = [URLQueryItem(name: "amount", value: String(amount)),
                          URLQueryItem(name: "token", value: token),
                          URLQueryItem(name: "difficulty", value: "easy"),
                          URLQueryItem(name: "category", value: "9")]
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    func loadQuestions(amount: Int = 20) {
        guard let url = getFullURL(amount: amount) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                let triviaModel = try JSONDecoder().decode(TriviaModel.self, from: dataResponse)
                DispatchQueue.main.async {
                    self.view.loadTrivia(model: triviaModel)
                }
            } catch {
                print("Error", error)
            }
        }
        task.resume()
    }
}
