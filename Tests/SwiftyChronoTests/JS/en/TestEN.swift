//
//  TestEn.swift
//  SwiftyChrono
//
//  Created by Jerry Chen on 1/23/17.
//  Copyright © 2017 Potix. All rights reserved.
//

import XCTest
import JavaScriptCore

class TestEN: ChronoJSXCTestCase {
    private let files = [
        "test_en",
        "test_en_casual",
        "test_en_dash",
        "test_en_deadline",
        "test_en_inter_std",
        "test_en_little_endian",
        "test_en_middle_endian",
        "test_en_month",
        "test_en_option_forward",
        "test_en_relative",
        "test_en_slash",
        "test_en_time_ago",
        "test_en_time_exp",
        "test_en_weekday",
    ]
    
    func testExample() {
        Chrono.sixMinutesFixBefore1900 = true
        // there are few words conflict with german day keywords
        Chrono.preferredLanguage = .english
        
        for fileName in files {
            let js = try! String(contentsOfFile: Bundle(identifier: "io.quire.lib.SwiftyChrono")!.path(forResource: fileName, ofType: "js")!)
            evalJS(js, fileName: fileName)
        }
    }
    
    func testMayConflict() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("May.")
        XCTAssertEqual(results.length, 1)
    }
    
    func test24Hour() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("1100")
        XCTAssertEqual(results.length, 1)
    }
    
    func test24Hour1() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("0100")
        XCTAssertEqual(results.length, 1)
    }
    
    func test24Hour2() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("100")
        XCTAssertEqual(results.length, 1)
    }
    
    func test24Hour3() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("110")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            XCTAssertEqual(result.text, "110")
            XCTAssertEqual(result.start.date.hour, 1)
            XCTAssertEqual(result.start.date.minute, 10)
        }
    }
    
    func test24HourInStrictMode() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono(modeOption: strictModeOption())
        
        let results = chrono.parse("32 August 2014")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            XCTAssertEqual(result.text, "2014")
            XCTAssertEqual(result.start.date.hour, 20)
            XCTAssertEqual(result.start.date.minute, 14)
        }
    }
    
    func test24HourInStrictMode2() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono(modeOption: strictModeOption())
        
        let results = chrono.parse("2014/22/29")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            XCTAssertEqual(result.text, "2014")
            XCTAssertEqual(result.start.date.hour, 20)
            XCTAssertEqual(result.start.date.minute, 14)
        }
    }
    
    func testDateTimeRefiner() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse(
            "b 20 Aug 2000",
            Date(), [
                .yearRemoval: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.day, 20)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.hour, 20)
            XCTAssertEqual(result.start.date.minute, 00)
        }
    }
    
    func testDateTimeRefiner2() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("20 Aug 2000 BC")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.day, 20)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertNotEqual(result.start.date.year, 2000)
        }
    }
    
    func testDateTimeRefiner3() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("20 Aug 1997 AD")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.day, 20)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.year, 1997)
        }
    }
    
    func testPastMonthOnly() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 8
        dateComponents.day = 18
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            "Aug",
            dateComponents.date!, [
                .forwardDate: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.year, 2018)
        }
    }
    
    func testSameDay() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 8
        dateComponents.day = 18
        dateComponents.hour = 15
        dateComponents.timeZone = TimeZone(abbreviation: "HKT")
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            "18 Aug 8pm",
            dateComponents.date!, [
                .forwardDate: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.hour, 20)
            XCTAssertEqual(result.start.date.day, 18)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.year, 2017)
        }
    }
    
    func testDateTimeRefinerPastYear() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        var dateComponents = DateComponents()
        dateComponents.year = 2017
        dateComponents.month = 8
        dateComponents.day = 18
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            "Aug 2000",
            dateComponents.date!, [
                .yearRemoval: 1,
                .forwardDate: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.year, 2018)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.hour, 20)
        }
    }
    
    func testDateTimeRefinerPastYearNextMonth() {
        Chrono.sixMinutesFixBefore1900 = true
        // Remark: Use all parsers
        // Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse(
            "17 Sep 2000",
            Date(), [
                .yearRemoval: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertNotEqual(result.start.date.year, 2000)
            XCTAssertEqual(result.start.date.month, 9)
            XCTAssertEqual(result.start.date.day, 17)
            XCTAssertEqual(result.start.date.hour, 20)
        }
    }
    
    func testDateTimeRefinerPastMonth() {
        Chrono.sixMinutesFixBefore1900 = true
        // Chrono.preferredLanguage = .english
        
        let now = Date()
        
        let chrono = Chrono()
        let results = chrono.parse(
            "1 Jan 1700",
            now, [
                .yearRemoval: 1,
                .forwardDate: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertTrue(result.start.date > now)
            XCTAssertEqual(result.start.date.year, now.year + 1)
            XCTAssertEqual(result.start.date.month, 1)
            XCTAssertEqual(result.start.date.day, 1)
            XCTAssertEqual(result.start.date.hour, 17)
        }
    }
    
    func testDateTimeRefinerFutureYear() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse("b 20 Aug 2020")
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.day, 20)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.year, 2020)
            XCTAssertNotEqual(result.start.date.hour, 20)
        }
    }
    
    func testDateTimeRefinerFutureYearUpperBound() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let chrono = Chrono()
        let results = chrono.parse(
            "b 20 Aug 2050",
            Date(), [
                .yearRemoval: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
            XCTAssertEqual(result.start.date.day, 20)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertNotEqual(result.start.date.year, 2050)
            XCTAssertEqual(result.start.date.hour, 20)
            XCTAssertEqual(result.start.date.minute, 50)
        }
    }
    
    func testOptionForwardWeekday() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let text = "Monday - Wednesday"
        
        var dateComponents = DateComponents()
        dateComponents.year = 2012
        dateComponents.month = 8
        dateComponents.day = 9
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            text,
            dateComponents.date!, [
                .forwardDate: 1
            ])
        
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.text, "Monday - Wednesday")
            XCTAssertEqual(result.start.date.year, 2012)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.day, 13)
            if let end = result.end {
                XCTAssertEqual(end.date.year, 2012)
                XCTAssertEqual(end.date.month, 8)
                XCTAssertEqual(end.date.day, 15)
            }
        }
        
        let text2 = "Wednesday - Monday"
        
        let results2 = chrono.parse(
            text2,
            dateComponents.date!, [
                .forwardDate: 1
            ])
        
        XCTAssertEqual(results2.length, 1)
        if let result2 = results2.first {
            // Weekdays will be sorted by weekday, thus reverted here.
            XCTAssertEqual(result2.text, "Wednesday - Monday")
            XCTAssertEqual(result2.start.date.year, 2012)
            XCTAssertEqual(result2.start.date.month, 8)
            XCTAssertEqual(result2.start.date.day, 13)
            if let end = result2.end {
                XCTAssertEqual(end.date.year, 2012)
                XCTAssertEqual(end.date.month, 8)
                XCTAssertEqual(end.date.day, 15)
            }
        }
    }
    
    func testOptionForwardWeekdaysOnly() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let text = "this Friday to next Monday"
        
        var dateComponents = DateComponents()
        dateComponents.year = 2016
        dateComponents.month = 8
        dateComponents.day = 4
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            text,
            dateComponents.date!, [
                .forwardDate: 1
            ])
        
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.text, "this Friday to next Monday")
            XCTAssertEqual(result.start.date.year, 2016)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.day, 5)
            if let end = result.end {
                XCTAssertEqual(end.date.year, 2016)
                XCTAssertEqual(end.date.month, 8)
                XCTAssertEqual(end.date.day, 8)
            }
        }
    }
    
    func testOptionForwardExactDay() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let text = "6 Aug to 12 Aug"
        
        var dateComponents = DateComponents()
        dateComponents.year = 2012
        dateComponents.month = 8
        dateComponents.day = 9
        dateComponents.calendar = Calendar.current
        
        let chrono = Chrono()
        let results = chrono.parse(
            text,
            dateComponents.date!, [
                .forwardDate: 1
            ])
        
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.text, "6 Aug to 12 Aug")
            XCTAssertEqual(result.start.date.year, 2013)
            XCTAssertEqual(result.start.date.month, 8)
            XCTAssertEqual(result.start.date.day, 6)
            if let end = result.end {
                XCTAssertEqual(end.date.year, 2013)
                XCTAssertEqual(end.date.month, 8)
                XCTAssertEqual(end.date.day, 12)
            }
        }
    }
}
