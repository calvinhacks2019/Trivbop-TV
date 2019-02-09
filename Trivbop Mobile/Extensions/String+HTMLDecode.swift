//
//  String+HTMLDecode.swift
//  Trivbop Mobile
//
//  Created by Austin Evans on 2/9/19.
//  Copyright © 2019 CalvinHacks2019. All rights reserved.
//

import Foundation

extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
            ], documentAttributes: nil).string

        return decoded ?? self
    }
}
