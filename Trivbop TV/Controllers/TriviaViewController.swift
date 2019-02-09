//
//  ViewController.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/8/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class TriviaViewController: UIViewController {

    var presenter: TriviaPresenter!

    var triviaModel = TriviaModel()

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

        presenter = TriviaPresenter(view: self)
        presenter.generateToken()
        presenter.loadQuestions()

        collectionView.delegate = self
        collectionView.dataSource = self

        questionLabel.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }

    func reloadView() {
        guard let question = triviaModel.getNext() else {
            presenter.loadQuestions()
            return
        }
        activityIndicator.stopAnimating()
        questionLabel.isHidden = false
        questionLabel.text = question.question.htmlDecoded
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
}

extension TriviaViewController: TriviaViewable {
    func loadTrivia(model: TriviaModel) {
        triviaModel = model
        reloadView()
    }

    func showError() {
        // TODO: Error handle
    }
}

extension TriviaViewController: UICollectionViewDelegate {

}

extension TriviaViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let question = triviaModel.getCurrent() else { return 0 }
        return question.incorrectAnswers.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerCell", for: indexPath) as! AnswerCollectionViewCell
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
