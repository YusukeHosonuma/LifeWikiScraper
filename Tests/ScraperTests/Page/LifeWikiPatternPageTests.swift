//
//  LifeWikiPatternPageTests.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
import Combine
@testable import Scraper

class LifeWikiPatternPageTests: XCTestCase {
    func testNext() throws {
        // Page 1.
        do {
            let html = getHTML("https://www.conwaylife.com/wiki/Category:Patterns")
            let page = LifeWikiPatternPage(html: html)
            XCTAssertEqual(page.links.first, URL(string: "https://www.conwaylife.com/wiki/$rats")!)
            XCTAssertEqual(page.links.count, 200)
            XCTAssertEqual(page.nextLink, URL(string: "https://www.conwaylife.com/w/index.php?title=Category:Patterns&pagefrom=Beacon+on+cover#mw-pages")!)
        }
        
        // Page 2.
        do {
            let html = getHTML("https://www.conwaylife.com/w/index.php?title=Category:Patterns&pagefrom=Beacon+on+cover#mw-pages")
            let page = LifeWikiPatternPage(html: html)
            XCTAssertEqual(page.links.first, URL(string: "https://www.conwaylife.com/wiki/Beacon_on_cover")!)
            XCTAssertEqual(page.nextLink, URL(string: "https://www.conwaylife.com/w/index.php?title=Category:Patterns&pagefrom=Cis-boat+on+dock#mw-pages")!)
        }
        
        // Page 7. (last)
        do {
            let html = getHTML("https://www.conwaylife.com/w/index.php?title=Category:Patterns&pagefrom=Tail#mw-pages")
            let page = LifeWikiPatternPage(html: html)
            XCTAssertEqual(page.links.first, URL(string: "https://www.conwaylife.com/wiki/Tail")!)
            XCTAssertEqual(page.links.last, URL(string: "https://www.conwaylife.com/wiki/Zweiback")!)
            XCTAssertNil(page.nextLink)
        }
    }
}
