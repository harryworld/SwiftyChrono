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
    
    func testDateTimeRefinerPastYear() {
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .english
        
        let now = Date()
        
        let chrono = Chrono()
        let results = chrono.parse(
            "Aug 2000",
            now, [
                .yearRemoval: 1,
                .forwardDate: 1
            ])
        XCTAssertEqual(results.length, 1)
        
        if let result = results.first {
            print(result.text)
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
    
}
