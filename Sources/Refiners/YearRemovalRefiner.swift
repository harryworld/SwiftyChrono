//
//  YearRemovalRefiner.swift
//  SwiftyChrono
//
//  Created by Harry Ng on 18/8/2017.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

/// Refine the result by removing past years and those beyond 2050
/// Keep only years between NOW and 2050 (exclusive).
class YearRemovalRefiner: Refiner {
    override func refine(text: String, results: [ParsedResult], opt: [OptionType : Int]) -> [ParsedResult] {
        
        if !opt.keys.contains(.yearRemoval) && !opt.keys.contains(.yearRemoval) {
            return results
        }
        
        var filteredResults = [ParsedResult]()
        
        for result in results {
            var r = result
            let refMoment = r.ref
            
            if (result.start.date.year < refMoment.year || result.start.date.year >= 2050)
                && result.yearBE == nil {
                r.start.knownValues.removeValue(forKey: .year)
                r.start.imply(.year, to: refMoment.year)
                if let yearText = result.yearText {
                    r.text = r.text.replacingOccurrences(of: yearText, with: "")
                }
            }
            filteredResults.append(r)
        }
        
        return filteredResults
    }
}
