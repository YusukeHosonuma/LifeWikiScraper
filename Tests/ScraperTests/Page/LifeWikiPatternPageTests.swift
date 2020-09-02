//
//  LifeWikiPageTests.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
@testable import Scraper

class LifeWikiPatternPageTests: XCTestCase {
    
    // $rats
    func testExample1() {
        let html = getHTML("https://www.conwaylife.com/wiki/$rats")
        let page = LifeWikiPatternPage(html: html)
        XCTAssertEqual(page.patternType, "Oscillator")
        XCTAssertEqual(page.discoveredBy, "David Buckingham")
        XCTAssertEqual(page.yearOfDiscovery, "1972")
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.rle"))
    }
    
    // B-heptomino
    func testExample2() {
        let html = getHTML("https://www.conwaylife.com/wiki/(13,1)c/31_Pseudo-B_climber")
        let page = LifeWikiPatternPage(html: html)
        XCTAssertEqual(page.patternType, "Crawler")
        XCTAssertEqual(page.discoveredBy, "Unknown")
        XCTAssertEqual(page.yearOfDiscovery, "Unknown")
        XCTAssertNil(page.plainTextURL)
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/131c31climber.rle"))
    }
    
    // B-heptomino
    func testExample3() {
        let html = getHTML("https://www.conwaylife.com/wiki/B-heptomino")
        let page = LifeWikiPatternPage(html: html)
        XCTAssertEqual(page.patternType, "Methuselah")
        XCTAssertEqual(page.discoveredBy, "John Conway")
        XCTAssertEqual(page.yearOfDiscovery, "1970")
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.rle"))
    }
}
