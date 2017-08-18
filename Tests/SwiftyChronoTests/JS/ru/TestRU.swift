//
//  TestRU.swift
//  SwiftyChrono
//
//  Created by Harry Ng on 18/8/2017.
//  Copyright © 2017 Potix. All rights reserved.
//

import XCTest

class TestRU: XCTestCase {
    
    var chrono: Chrono!
    var refDate: Date!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Chrono.sixMinutesFixBefore1900 = true
        Chrono.preferredLanguage = .russian
        
        chrono = Chrono()
        
        refDate = DateComponents(
                    calendar: Calendar.current,
                    year: 2017,
                    month: 8,
                    day: 18,
                    hour: 23
                    ).date
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNow() {
        let results = chrono.parse("теперь")
        XCTAssertEqual(results.length, 1)
    }
    
    func testTonight() {
        let results = chrono.parse("сегодня вечером")
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.start.date.hour, 22)
        }
    }
    
    func testLastNight() {
        let results = chrono.parse("прошлой ночью", refDate, [:])
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.start.date.day, refDate.day - 1)
            XCTAssertEqual(result.start.date.hour, 0)
        }
    }
    
    func testTomorrow() {
        let results = chrono.parse("завтра", refDate, [:])
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.start.date.day, refDate.day + 1)
            XCTAssertEqual(result.start.date.hour, 12)
        }
    }
    
    func testYesterday() {
        let results = chrono.parse("вчера")
        XCTAssertEqual(results.length, 1)
        if let result = results.first {
            XCTAssertEqual(result.start.date.day, Date().day - 1)
            XCTAssertEqual(result.start.date.hour, 12)
        }
    }
    
}
