//
//  LeaderboardViewController.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var connection: Connectivity!

    var players: [Player]!

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity
        players = connection.players
        sortPlayers()

        headerLabel.text = "LEADERBOARD"
        headerLabel.font = UIFont(name: "Bebas Neue", size: 175.0)

        collectionView.delegate = self
        collectionView.dataSource = self

        send()
    }

    func sortPlayers() {
        players.sort { (player1, player2) -> Bool in
            return player1.points > player2.points
        }
        collectionView.reloadData()
    }

    func encode() -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            var message = MessageSendable(type: .showLeaderboard)
            let personsMessage = PersonMessages(personsModel: players)
            let jsonSubData = try jsonEncoder.encode(personsMessage)
            message.data = jsonSubData

            let jsonData = try jsonEncoder.encode(message)

            if let jsonString = String(data: jsonSubData, encoding: .utf8) {
                print(jsonString)
            }
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
            collectionView.reloadData()
            return jsonData
        } catch {
            print("Leaderboard FAIL!")
        }
        return nil
    }

    func send() {
        guard let data = encode() else { return }
        connection.sendData(data: data, to: nil)
    }
}

extension LeaderboardViewController: UICollectionViewDelegate {

}

extension LeaderboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return players.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCollectionViewCell else { return UICollectionViewCell() }
        cell.playerLabel.text = "\(indexPath.row + 1). \(players[indexPath.row].username)"
        cell.pointsLabel.text = "\(players[indexPath.row].points)"
        cell.color = players[indexPath.row].color
        cell.barLength(points: players[indexPath.row].points, mostPoints: players[0].points)
        return cell
    }


}

