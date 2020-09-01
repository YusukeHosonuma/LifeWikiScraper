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
    func getHTML(_ urlString: String) -> String {
        let exp = expectation(description: "")
        
        var result: String!
        
        downloader.download(url: URL(string: urlString)!) { (content) in
            result = content!
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
        return result
    }
}
