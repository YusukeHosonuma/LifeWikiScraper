//
//  LifeWikiPage.swift
//  LifeWikiScraper
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import Foundation
import SwiftSoup
import Combine

private let downloader = CachedHTTPTextDownloader(cacheDirectory: URL(fileURLWithPath: "./cache/pattern/"))

// e.g. https://www.conwaylife.com/wiki/$rats
public struct LifeWikiPatternPage {
    let plainTextURL: URL?
    let rleURL: URL?
    
    public static func fetch(url: URL) -> AnyPublisher<LifeWikiPatternPage, Never> {
        downloader.downloadPublisher(url: url)
            .map { html in
                LifeWikiPatternPage(html: html!)
            }
            .eraseToAnyPublisher()
    }
    
    public init(html: String) {
        let doc = try! SwiftSoup.parse(html)
        // document.querySelectorAll('.infobox_table tr').filter(x => x.querySelector("a[title='Plaintext']"))
        let xs = try! doc.select(".infobox_table tr")
        
        do {
            let tr = xs.filter { try! !$0.select("a[title='Plaintext']").isEmpty() }.first
            if let tr = tr {
                let textLink = try! tr.select("a.external.text")
                plainTextURL = URL(string: try! textLink.attr("href"))!
            } else {
                plainTextURL = nil
            }
        }
        
        rleURL = xs
            .filter { try! !$0.select("a[title='RLE']").isEmpty() }
            .last // TODO: 暫定
            .flatMap {
                let textLink = try! $0.select("a.external.text")
                return URL(string: try! textLink.attr("href"))!
            }
    }
}

