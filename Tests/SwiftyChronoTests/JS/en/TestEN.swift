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
            let js = try! String(contentsOfFile: Bundle(identifier: "io.quire.lib.SwiftyChrono.iOS")!.path(forResource: fileName, ofType: "js")!)
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
}
