//
//  ENTimeExpressionParser.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import Foundation

private let FIRST_REG_PATTERN = "(^|\\s|T)" +
    "(?:(?:at|from)\\s*)?" +
    "(\\d{1,4}|noon|midnight)" +
    "(?:" +
        "(?:\\.|\\:|\\：)(\\d{1,2})" +
        "(?:" +
            "(?:\\:|\\：)(\\d{2})" +
        ")?" +
    ")?" +
    "(?:\\s*(A\\.M\\.|P\\.M\\.|AM?|PM?))?" +
    "(?=\\W|$)"

private let SECOND_REG_PATTERN = "^\\s*" +
    "(\\-|\\–|\\~|\\〜|to|\\?)\\s*" +
    "(\\d{1,4})" +
    "(?:" +
        "(?:\\.|\\:|\\：)(\\d{1,2})" +
        "(?:" +
            "(?:\\.|\\:|\\：)(\\d{1,2})" +
        ")?" +
    ")?" +
    "(?:\\s*(A\\.M\\.|P\\.M\\.|AM?|PM?))?" +
    "(?=\\W|$)"

private let PATTERN_24HR = "^([01]?\\d|2[0-3]):?([0-5]\\d)$"

private let hourGroup = 2
private let minuteGroup = 3
private let secondGroup = 4
private let amPmHourGroup = 5

public class ENTimeExpressionParser: Parser {
    override var pattern: String { return FIRST_REG_PATTERN }
    
    override public func extract(text: String, ref: Date, match: NSTextCheckingResult, opt: [OptionType: Int]) -> ParsedResult? {
        // This pattern can be overlaped Ex. [12] AM, 1[2] AM
        let idx = match.rangeAt(0).location
        let str = text.substring(from: idx - 1, to: idx)
        if idx > 0 && NSRegularExpression.isMatch(forPattern: "\\w", in: str) {
            return nil
        }
        
        var (matchText, index) = matchTextAndIndex(from: text, andMatchResult: match)
        var result = ParsedResult(ref: ref, index: index, text: matchText)
        result.tags[.enTimeExpressionParser] = true
        
        result.start.imply(.day, to: ref.day)
        result.start.imply(.month, to: ref.month)
        result.start.imply(.year, to: ref.year)
        
        var hour = 0
        var minute = 0
        var meridiem = -1
        
        // ----- Second
        if match.isNotEmpty(atRangeIndex: secondGroup) {
            if let second = Int(match.string(from: text, atRangeIndex: secondGroup)) {
                if second >= 60 {
                    return nil
                }
                
                result.start.assign(.second, value: second)
            }
        }
        
        // ----- Hours
        let hourText = match.isNotEmpty(atRangeIndex: hourGroup) ? match.string(from: text, atRangeIndex: hourGroup).lowercased() : ""
        if hourText == "noon" {
            meridiem = 1
            hour = 12
        } else if hourText == "midnight" {
            meridiem = 0
            hour = 0
        } else {
            switch hourText.characters.count {
            case 3:
                hour = Int(hourText.substring(from: 0, to: 1)) ?? 0
                minute = Int(hourText.substring(from: 1, to: 3)) ?? 0
            case 4:
                hour = Int(hourText.substring(from: 0, to: 2)) ?? 0
                minute = Int(hourText.substring(from: 2, to: 4)) ?? 0
            default:
                hour = Int(hourText) ?? 0
            }
        }
        
        // ----- Minutes
        if match.isNotEmpty(atRangeIndex: minuteGroup) {
            minute = Int(match.string(from: text, atRangeIndex: minuteGroup)) ?? 0
        } else if hour > 100 {
            minute = hour % 100
            hour = hour/100
        }
        
        if minute >= 60 || hour > 24 {
            return nil
        }
        
        if hour >= 12 {
            meridiem = 1
        }
        
        // ----- AM & PM
        if match.isNotEmpty(atRangeIndex: amPmHourGroup) {
            if hour > 12 {
                return nil
            }
            
            let ampm = String(match.string(from: text, atRangeIndex: amPmHourGroup).characters.first!).lowercased()
            if ampm == "a" {
                meridiem = 0
                if hour == 12 {
                    hour = 0
                }
            }
            
            if ampm == "p" {
                meridiem = 1
                if hour != 12 {
                    hour += 12
                }
            }
        }
        
        result.start.assign(.hour, value: hour)
        result.start.assign(.minute, value: minute)
        if meridiem >= 0 {
            result.start.assign(.meridiem, value: meridiem)
        } else {
            result.start.imply(.meridiem, to: hour < 12 ? 0 : 1)
        }
        
        // ==============================================================
        //                  Extracting the 'to' chunk
        // ==============================================================
        
        let regex = try? NSRegularExpression(pattern: SECOND_REG_PATTERN, options: .caseInsensitive)
        let secondText = text.substring(from: result.index + result.text.characters.count)
        guard let match = regex?.firstMatch(in: secondText, range: NSRange(location: 0, length: secondText.characters.count)) else {
            // Not accept number only result
            if NSRegularExpression.isMatch(forPattern: "^\\d+$", in: result.text) {
                
                // Except 24 hour format
                if NSRegularExpression.isMatch(forPattern: PATTERN_24HR, in: result.text) {
                    return result
                }
                
                return nil
            }
            
            return result
        }
        matchText = match.string(from: secondText, atRangeIndex: 0)
        
        // Pattern "YY.YY -XXXX" is more like timezone offset
        if NSRegularExpression.isMatch(forPattern: "^\\s*(\\+|\\-)\\s*\\d{3,4}$", in: matchText) {
            return result
        }
        
        if result.end == nil {
            result.end = ParsedComponents(components: nil, ref: result.start.date)
        }
        
        hour = 0
        minute = 0
        meridiem = -1
        
        // ----- Second
        if match.isNotEmpty(atRangeIndex: secondGroup) {
            let second = Int(match.string(from: secondText, atRangeIndex: secondGroup)) ?? 0
            if second >= 60 {
                return nil
            }
            
            result.end?.assign(.second, value: second)
        }
        
        hour = Int(match.string(from: secondText, atRangeIndex: hourGroup)) ?? 0
        
        // ----- Minute
        if match.isNotEmpty(atRangeIndex: minuteGroup) {
            minute = Int(match.string(from: secondText, atRangeIndex: minuteGroup)) ?? 0
            if minute >= 60 {
                return result
            }
        } else if hour > 100 {
            minute = hour % 100
            hour = hour / 100
        }
        
        if minute >= 60 || hour > 24 {
            return nil
        }
        
        if hour >= 12 {
            meridiem = 1
        }
        
        // ----- AM & PM
        if match.isNotEmpty(atRangeIndex: amPmHourGroup) {
            if hour > 12 {
                return nil
            }
            
            let ampm = String(match.string(from: secondText, atRangeIndex: amPmHourGroup).characters.first!).lowercased()
            if ampm == "a" {
                meridiem = 0
                if hour == 12 {
                    hour = 0
                    if !result.end!.isCertain(component: .day) {
                        result.end!.imply(.day, to: result.end![.day]! + 1)
                    }
                }
            }
            
            if ampm == "p" {
                meridiem = 1
                if hour != 12 {
                    hour += 12
                }
            }
            
            if !result.start.isCertain(component: .meridiem) {
                if meridiem == 0 {
                    result.start.imply(.meridiem, to: 0)
                    
                    if result.start[.hour] == 12 {
                        result.start.assign(.hour, value: 0)
                    }
                } else {
                    result.start.imply(.meridiem, to: 1)
                    
                    if let hour = result.start[.hour], hour != 12 {
                        result.start.assign(.hour, value: hour + 12)
                    }
                }
            }
        }
        
        result.text = result.text + matchText
        result.end!.assign(.hour, value: hour)
        result.end!.assign(.minute, value: minute)
        if meridiem >= 0 {
            result.end!.assign(.meridiem, value: meridiem)
        } else {
            let startAtPm = result.start.isCertain(component: .meridiem) && result.start[.meridiem]! == 1
            if startAtPm && result.start[.hour]! > hour {
                // 10pm - 1 (am)
                result.end!.imply(.meridiem, to: 0)
            } else if hour > 12 {
                result.end!.imply(.meridiem, to: 1)
            }
        }
        
        if result.end!.date.timeIntervalSince1970 < result.start.date.timeIntervalSince1970 {
            result.end?.imply(.day, to: result.end![.day]! + 1)
        }
        
        return result
    }
}
