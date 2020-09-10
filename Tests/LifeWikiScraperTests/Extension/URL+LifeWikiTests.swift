//
//  URL+LifeWikiTests.swift
//  ScraperTests
//
//  Created by Yusuke Hosonuma on 2020/09/03.
//

import XCTest
@testable import LifeWikiScraper

class URLLifeWikiTests: XCTestCase {
    func testIsPatternURL() throws {
        XCTAssertFalse(URL(string: "https://conwaylife.com/wiki/$rats")!.isTemplateURL)
        XCTAssertTrue(URL(string: "https://conwaylife.com/wiki/Template:Agar")!.isTemplateURL)
    }
}
