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
    public let title: String
    public let patternType: String
    public let discoveredBy: String
    public let yearOfDiscovery: String
    public let plainTextURL: URL?
    public let rleURL: URL?
    public let sourceURL: URL
    
    public static func fetch(url: URL) -> AnyPublisher<LifeWikiPatternPage?, Never> {
        downloader.downloadPublisher(url: url, type: .html)
            .map { html in
                guard let html = html else {
                    print("⏭ Pattern page is not fetched (\(url))")
                    return nil
                }
                print("🔍 Parse LifeWikiPatternPage is started. (\(url))")
                return LifeWikiPatternPage(html: html, source: url)
            }
            .eraseToAnyPublisher()
    }
    
    public init?(html: String, source: URL) {
        self.sourceURL = source
        
        let doc = try! SwiftSoup.parse(html)
        
        title = try! doc.select("h1").html()
        
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
        
        // .inbox
        guard let _ = try! doc.select(".infobox").first() else {
            print("⏭ .infobox is not found. (\(source))")
            return nil
        }
        patternType = Self.valueFromInfoTable(doc, name: "Pattern type")
        discoveredBy = Self.valueFromInfoTable(doc, name: "Discovered by")
        yearOfDiscovery = Self.valueFromInfoTable(doc, name: "Year of discovery")

        rleURL = xs
            .filter { try! !$0.select("a[title='RLE']").isEmpty() }
            .last // TODO: 暫定
            .flatMap {
                let textLink = try! $0.select("a.external.text")
                return URL(string: try! textLink.attr("href"))!
            }
    }
    
    private static func valueFromInfoTable(_ doc: Document, name: String) -> String {
        let infobox = try! doc.select(".infobox").first()!
        let infoboxTrs = try! infobox.select("tr")
        return infoboxTrs
            .filter {
                guard let th = try! $0.select("th").first() else { return false }
                return try! th.html().contains("\(name)")
            }
            .map {
                if let a = try! $0.select("a").first() {
                    return try! a.html()
                } else {
                    // Always 'Unknown' maybe.
                    return try! $0.select("td").first()!.html()
                }
            }
            .first!
    }
}

