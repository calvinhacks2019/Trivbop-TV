//
//  ViewController.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class TriviaViewController: UIViewController {

    var presenter: TriviaPresenter!

    var triviaModel = TriviaModel()

    var connection: Connectivity!

    var currentQuestion: Question?

    var numberOfTriviaPerRound = 10
    var currentTrivia = 0 {
        didSet {
            headerLabel.text = "QUESTION \(currentTrivia)/\(numberOfTriviaPerRound)"
        }
    }

    @IBOutlet weak var progressView: UIProgressView!
    //let maxTime: Double = 15        // Seconds
    var progressValue: Double = 0


    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var timesUpLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var questionLabel: UILabel!
    //@IBOutlet weak var innerViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)

    let colors = [#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.937254902, green: 0.2784313725, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.02352941176, green: 0.8392156863, blue: 0.6274509804, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity
        connection.delegate = self

        presenter = TriviaPresenter(view: self)
        presenter.generateToken()
        presenter.loadQuestions()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPrefetchingEnabled = false

        questionLabel.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true

        questionLabel.font = UIFont(name: "Bebas Neue", size: 79.0)

        headerLabel.font = UIFont(name: "Bebas Neue", size: 175.0)

        timesUpLabel.font = UIFont(name: "Bebas Neue", size: 400.0)
        timesUpLabel.textColor = UIColor.red
    }

    @objc func updateProgress() {
        progressValue = progressValue + 0.01
        progressView.progress = Float(progressValue)
        if progressValue <= 1.0 {
            perform(#selector(updateProgress), with: nil, afterDelay: 0.1)
        } else {
            timeUp()
        }
    }

    let group = DispatchGroup()

    func timeUp() {
        sendExpireQuestion()

        UIView.animate(withDuration: 2.0) {
            self.timesUpLabel.alpha = 1
        }

        UIView.animate(withDuration: 3.0) {
            var cells = [UICollectionViewCell]()
            var answerCell: UICollectionViewCell?

            guard let question = self.currentQuestion else {  return }
            for j in 0...question.incorrectAnswers.count {
                if let cell = self.collectionView.cellForItem(at: NSIndexPath(row: j, section: 0) as IndexPath) as? AnswerCollectionViewCell {
                    cell.alpha = 0.25
                    cells.append(cell)
                    if cell.label.text == question.correctAnswer.htmlDecoded {
                        answerCell = cell
                    }
                }
                if let one = self.collectionView.cellForItem(at: NSIndexPath(row: 0, section: 0) as IndexPath) as? AnswerCollectionViewCell {
                    one.alpha = 0.25
                }
            }
            guard let cell = answerCell else { return }
            self.revealAnswer(delay: 3, correctCell: cell)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            OperationQueue.main.addOperation {
                UIView.animate(withDuration: 1.0) {
                    self.timesUpLabel.alpha = 0
                }
            }
        })
    }

    func revealAnswer(delay: Int, correctCell: UICollectionViewCell) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            OperationQueue.main.addOperation {
                self.sendRevealAnswer()
                UIView.animate(withDuration: 3.0) {
                    correctCell.alpha = 1
                }
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay + 7), execute: {
            OperationQueue.main.addOperation {
                self.reloadView()
            }
        })
    }

    func reloadView() {
        guard let question = triviaModel.getNext() else {
            presenter.loadQuestions()
            return
        }
        currentTrivia += 1
        if currentTrivia > numberOfTriviaPerRound {
            performSegue(withIdentifier: "ShowLeaderboard", sender: nil)
        }
        progressValue = 0
        perform(#selector(updateProgress), with: nil, afterDelay: 0.1)
        activityIndicator.stopAnimating()
        questionLabel.isHidden = false
        questionLabel.text = question.question.htmlDecoded
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        currentQuestion = triviaModel.getCurrent()
        sendCurrentQuestion(question: question)
    }

    func displayAlert() {
        let alert = UIAlertController(title: "Failed to encode", message: "We could not send message to one or more device", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func encodeQuestion() -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            var message = MessageSendable(type: .question)
            let jsonSubData = try jsonEncoder.encode(triviaModel.getCurrent())
            message.data = jsonSubData

            let jsonData = try jsonEncoder.encode(message)

            if let jsonString = String(data: jsonSubData, encoding: .utf8) {
                print(jsonString)
            }
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }

            return jsonData
        } catch {
            displayAlert()
        }
        return nil
    }

    func encodeExpireQuestion() -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let message = MessageSendable(type: .expireQuestion)
            let jsonData = try jsonEncoder.encode(message)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }

            return jsonData
        } catch {
            displayAlert()
        }
        return nil
    }

    func encodeRevealAnswer() -> Data? {
        let jsonEncoder = JSONEncoder()
        do {
            let message = MessageSendable(type: .revealResult)
            let jsonData = try jsonEncoder.encode(message)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }

            return jsonData
        } catch {
            displayAlert()
        }
        return nil
    }

    func sendCurrentQuestion(question: Question) {
        guard let data = encodeQuestion() else { return }
        connection.sendData(data: data, to: nil)
    }

    func sendExpireQuestion() {
        guard let data = encodeExpireQuestion() else { return }
        connection.sendData(data: data, to: nil)
    }

    func sendRevealAnswer() {
        guard let data = encodeRevealAnswer() else { return }
        connection.sendData(data: data, to: nil)
    }
}

extension TriviaViewController: TriviaViewable {
    func loadTrivia(model: TriviaModel) {
        triviaModel = model
        progressValue = 0
        reloadView()
    }

    func showError() {
        // TODO: Error handle
    }
}

extension TriviaViewController: ConnectivityDelegate {
    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String]) {
        // TODO: Show if a player looses connection by cross refrencing list in app delegate
    }

    func recieveMessage(type: MessageType, data: Data?, from peer: MCPeerID) {
        OperationQueue.main.addOperation {
            switch type {
            case .answer:
                do {
                    if let jsonString = String(data: data!, encoding: .utf8) {
                        print(jsonString)
                    }
                    let jsonDecoder = JSONDecoder()
                    let answer = try jsonDecoder.decode(Answer.self, from: data!)

                    if answer.isCorrect {
                        let time = answer.timeElapsed

                        self.connection.players.forEach { (player) in
                            if player.peerID == peer {
                                player.addPoint(timeElapsed: time)
                            }
                        }
                    }

                } catch {
                    let alert = UIAlertController(title: "Failed to get question", message: "\(error)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            default:
                break
            }
        }
    }

    func error(message _: String) {
        // TODO: Handle errors
    }


}

extension TriviaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let question = triviaModel.getCurrent() else { return 0 }
        return question.incorrectAnswers.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerCell", for: indexPath) as! AnswerCollectionViewCell
        cell.label.font = UIFont(name: "Bebas Neue", size: 88.0)
        cell.alpha = 1
        cell.label.adjustsFontSizeToFitWidth = true
        cell.label.text = triviaModel.getCurrent()?.shuffledAnswers[indexPath.row].htmlDecoded
        cell.backgroundColor = colors[indexPath.row]
        return cell
    }
}

extension TriviaViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpaceHorizontal = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpaceHorizontal
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: 154)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
