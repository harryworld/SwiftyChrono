//
//  UnlikelyFormatFilter.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/24/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let PATTERN = "^\\d*(\\.\\d*)?$"
private let regex = try! NSRegularExpression(pattern: PATTERN, options: NSRegularExpression.Options.caseInsensitive)
private let PATTERN_24HR = "^([01]?\\d|2[0-3]):?([0-5]\\d)$"
private let regex_24 = try! NSRegularExpression(pattern: PATTERN_24HR, options: NSRegularExpression.Options.caseInsensitive)

class UnlikelyFormatFilter: Filter {
    override func isValid(text: String, result: ParsedResult, opt: [OptionType: Int]) -> Bool {
        let textToMatch = result.text.replacingOccurrences(of: " ", with: "")
        let match = regex.firstMatch(in: textToMatch, range: NSRange(location: 0, length: textToMatch.count))
        
        if match != nil {
            let match24Hour = regex_24.firstMatch(in: textToMatch, range: NSRange(location: 0, length: textToMatch.count))
            return match24Hour != nil
        } else {
            return true
        }
    }
}
