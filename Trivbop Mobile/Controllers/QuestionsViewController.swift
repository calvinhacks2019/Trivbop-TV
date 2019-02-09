//
//  QuestionsViewController.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class QuestionsViewController: UIViewController {
    var connection: Connectivity!

    var startPoint: Date?

    var userAnswer: String?

    var question: Question? {
        didSet {
            if question == nil {
                questionLabel.alpha = 0
                collectionView.alpha = 0
                startPoint = nil
                selectedCell = nil
            } else {
                userAnswer = nil
                questionLabel.alpha = 1
                questionLabel.text = question?.question.htmlDecoded
                collectionView.alpha = 1
                collectionView.isUserInteractionEnabled = true
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
                startPoint = Date()
            }
        }
    }

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var answerCell: AnswerCell?
    var selectedCell: AnswerCell?

    let colors = [#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.937254902, green: 0.2784313725, blue: 0.4352941176, alpha: 1), #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), #colorLiteral(red: 0.02352941176, green: 0.8392156863, blue: 0.6274509804, alpha: 1)]

    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(top: 16.0,
                                             left: 20.0,
                                             bottom: 16.0,
                                             right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        connection = appDelegate.connectivity
        connection.delegate = self

        collectionView.delegate = self
        collectionView.dataSource = self

        questionLabel.font = UIFont(name: "Bebas Neue", size: 40.0)
    }

    func encode(answer: String) -> Data? {
        var timeElapsed: Double!
        if let starting = startPoint {
            timeElapsed = starting.timeIntervalSinceNow * -1
        } else {
            timeElapsed = 10
        }
        let jsonEncoder = JSONEncoder()
        do {
            var message = MessageSendable(type: .answer)
            let correct = answer == question!.correctAnswer
            let jsonSubData = try jsonEncoder.encode(Answer(answer: answer, time: timeElapsed, isCorrect: correct))
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
            let alert = UIAlertController(title: "Failed to encode", message: "We could not send message to one or more device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        return nil
    }

    func expireQuestion(timeUp: Bool) {
        guard collectionView.isUserInteractionEnabled == true else { return }

        collectionView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 3.0) {
            var cells = [UICollectionViewCell]()
            // assuming tableView is your self.tableView defined somewhere
            guard let question = self.question else { return }
            for j in 0...question.incorrectAnswers.count
            {
                if let cell = self.collectionView.cellForItem(at: NSIndexPath(row: j, section: 0) as IndexPath) as? AnswerCell {
                    cell.backgroundColor = cell.backgroundColor?.darker(by: 50)
                    cells.append(cell)
                    cell.label.textColor = cell.label.textColor.darker(by: 50)
                    if cell.label.text == question.correctAnswer.htmlDecoded {
                        self.answerCell = cell
                    }
                }
            }
        }
    }

    func revealAnswer() {
        guard let correctCell = self.answerCell else {
                return
        }
        UIView.animate(withDuration: 3.0) {
            correctCell.backgroundColor = correctCell.backgroundColor?.lighter(by: 50)
            correctCell.label.textColor = correctCell.label.textColor.lighter(by: 50)
        }
        if correctCell.label.text == userAnswer {
            correctCell.label.text = correctCell.label.text! + " ✅"
        } else {
            if selectedCell != nil {
                selectedCell?.label.text = selectedCell!.label.text! + " 😢"
            }
            correctCell.label.text = correctCell.label.text! + " ✅"
        }
    }
}

extension QuestionsViewController: ConnectivityDelegate {
    func connectedDevicesChanged(manager: Connectivity, connectedDevices: [String]) {
        // probably just ignore
    }

    func recieveMessage(type: MessageType, data: Data?) {
        OperationQueue.main.addOperation {
            do {
                if let data = data,
                    let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                }
                let jsonDecoder = JSONDecoder()
                switch type {
                case .question:
                    let question = try jsonDecoder.decode(Question.self, from: data!)
                    self.question = question
                case .expireQuestion:
                    self.expireQuestion(timeUp: true)
                case .revealResult:
                    self.revealAnswer()
                default:
                    break
                }
            } catch {
                let alert = UIAlertController(title: "Failed to get question", message: "\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    func error(message: String) {
        // TODO: Error handling
    }
}

extension QuestionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.backgroundColor = cell.backgroundColor?.darker()
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.backgroundColor = colors[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AnswerCell,
            let userAnswer = cell.label.text else { return }
        selectedCell = cell
        if let data = encode(answer: userAnswer) {
            self.userAnswer = userAnswer
            connection.sendData(data: data)
            expireQuestion(timeUp: false)
        }
    }
}

extension QuestionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let question = question else { return 0 }
        return question.incorrectAnswers.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
        cell.label.text = question!.shuffledAnswers[indexPath.row].htmlDecoded
        cell.backgroundColor = colors[indexPath.row]
        cell.label.font = UIFont(name: "Bebas Neue", size: 35.0)
        cell.label.textColor = UIColor.white
        cell.label.adjustsFontSizeToFitWidth = true
        return cell
    }
}

extension QuestionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpaceHorizontal = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpaceHorizontal
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: 100)
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
