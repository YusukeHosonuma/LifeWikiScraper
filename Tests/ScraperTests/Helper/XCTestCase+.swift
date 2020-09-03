//
//  XCTestCase+.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
@testable import Scraper

// TODO: システムのキャッシュディレクトリが理想かもだけどとりあえず妥協
let downloader = CachedHTTPTextDownloader(cacheDirectory: URL(fileURLWithPath: "./cache"), useMD5: true)

extension XCTestCase {
    func getContent(_ urlString: String, type: ContentType) -> String {
        getContent(url: URL(string: urlString)!, type: type)
    }

    func getContent(url: URL, type: ContentType) -> String {
        let exp = expectation(description: "")
        
        var result: String!
        
        downloader.download(url: url, type: type) { (content) in
            result = content!
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return result
    }
}
