//
//  YearRemovalRefiner.swift
//  SwiftyChrono
//
//  Created by Harry Ng on 18/8/2017.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

class YearRemovalRefiner: Refiner {
    override func refine(text: String, results: [ParsedResult], opt: [OptionType : Int]) -> [ParsedResult] {
        
        let now = Date()
        
        var filteredResults = [ParsedResult]()
        
        for result in results {
            var r = result
            
            if (result.start.date.year < now.year || result.start.date.year >= 2050)
                && result.yearBE == nil {
                r.start.knownValues.removeValue(forKey: .year)
                r.start.imply(.year, to: now.year)
                if let yearText = result.yearText {
                    r.text = r.text.replacingOccurrences(of: yearText, with: "")
                }
            }
            filteredResults.append(r)
        }
        
        return filteredResults
    }
}
