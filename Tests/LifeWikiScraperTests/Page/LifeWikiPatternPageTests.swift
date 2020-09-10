//
//  LifeWikiPageTests.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
@testable import LifeWikiScraper

class LifeWikiPatternPageTests: XCTestCase {
    
    // $rats
    func testExample1() throws {
        let url = URL(string: "https://www.conwaylife.com/wiki/$rats")!
        let page = try XCTUnwrap(LifeWikiPatternPage(html: getContent(url: url, type: .html), source: url))
        XCTAssertEqual(page.title, "$rats")
        XCTAssertEqual(page.patternType, "Oscillator")
        XCTAssertEqual(page.discoveredBy, "David Buckingham")
        XCTAssertEqual(page.yearOfDiscovery, "1972")
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.rle"))
        XCTAssertEqual(page.sourceURL, url)
    }
    
    // 31_Pseudo-B_climber
    func testExample2() throws {
        let url = URL(string: "https://www.conwaylife.com/wiki/(13,1)c/31_Pseudo-B_climber")!
        let page = try XCTUnwrap(LifeWikiPatternPage(html: getContent(url: url, type: .html), source: url))
        XCTAssertEqual(page.title, "(13,1)c/31 Pseudo-B climber")
        XCTAssertEqual(page.patternType, "Crawler")
        XCTAssertEqual(page.discoveredBy, "Unknown")
        XCTAssertEqual(page.yearOfDiscovery, "Unknown")
        XCTAssertNil(page.plainTextURL)
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/131c31climber.rle"))
        XCTAssertEqual(page.sourceURL, url)
    }
    
    // B-heptomino
    func testExample3() throws {
        let url = URL(string: "https://www.conwaylife.com/wiki/B-heptomino")!
        let page = try XCTUnwrap(LifeWikiPatternPage(html: getContent(url: url, type: .html), source: url))
        XCTAssertEqual(page.title, "B-heptomino")
        XCTAssertEqual(page.patternType, "Methuselah")
        XCTAssertEqual(page.discoveredBy, "John Conway")
        XCTAssertEqual(page.yearOfDiscovery, "1970")
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.rle"))
        XCTAssertEqual(page.sourceURL, url)
    }
    
    func testExample4() throws {
        let url = URL(string: "https://conwaylife.com/wiki/Reverse_caber-tosser")!
        let page = LifeWikiPatternPage(html: getContent(url: url, type: .html), source: url)
        XCTAssertNil(page)
    }
    
    func testExample5() throws {
        let url = URL(string: "https://conwaylife.com/wiki/Reverse_caber-tosser")!
        let page = LifeWikiPatternPage(html: getContent(url: url, type: .html), source: url)
        XCTAssertNil(page)
    }
}
