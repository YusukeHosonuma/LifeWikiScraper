//
//  CachedHTTPTextDownloaderTests.swift
//  ScraperTests
//
//  Created by Yusuke Hosonuma on 2020/09/03.
//

import XCTest
@testable import LifeWikiScraper

class CachedHTTPTextDownloaderTests: XCTestCase {
    func testExample() throws {
        let url = URL(fileURLWithPath: "./CachedHTTPTextDownloaderTests")
        let downloader = CachedHTTPTextDownloader(cacheDirectory: url, useMD5: true)
        
        let exp = expectation(description: "#")
        downloader.download(url: URL(string: "https://www.conwaylife.com/patterns/fireship.rle")!, type: .plainText) { (content) in
            XCTAssertNotNil(content)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
}
