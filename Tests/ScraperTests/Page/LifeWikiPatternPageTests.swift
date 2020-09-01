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
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/rats.rle"))
    }
    
    // B-heptomino
    func testExample2() {
        let html = getHTML("https://www.conwaylife.com/wiki/B-heptomino")
        let page = LifeWikiPatternPage(html: html)
        XCTAssertEqual(page.plainTextURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.cells"))
        XCTAssertEqual(page.rleURL,
                       URL(string: "https://www.conwaylife.com/patterns/bheptomino.rle"))
    }
}
