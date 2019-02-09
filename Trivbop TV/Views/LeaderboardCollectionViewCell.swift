//
//  LeaderboardCollectionViewCell.swift
//  Trivbop TV
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import UIKit

class LeaderboardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var constraint: NSLayoutConstraint!

    static let maxHeight: CGFloat = 700

    override func awakeFromNib() {
        super.awakeFromNib()

        playerLabel.font = UIFont(name: "Bebas Neue", size: 70.0)
        pointsLabel.font = UIFont(name: "Bebas Neue", size: 70.0)

        playerLabel.sizeToFit()
    }

    var color: UIColor? {
        didSet {
            blackView.backgroundColor = color
        }
    }

    func barLength(points: Int, mostPoints: Int) {
        guard mostPoints != 0 else {
            constraint.constant = LeaderboardCollectionViewCell.maxHeight
            return
        }
        let width: CGFloat = CGFloat(points / mostPoints) * LeaderboardCollectionViewCell.maxHeight
        constraint.constant = width
        self.invalidateIntrinsicContentSize()
        blackView.invalidateIntrinsicContentSize()
    }
}
