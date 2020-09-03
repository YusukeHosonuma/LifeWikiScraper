//
//  LifeWikiPatternPage.swift
//  LifeWikiScraper
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import SwiftSoup
import Foundation
import Combine

private let firstPageURL = URL(string: "https://www.conwaylife.com/wiki/Category:Patterns")!
private let downloader = CachedHTTPTextDownloader(cacheDirectory: URL(fileURLWithPath: "./cache/all/"), useMD5: true)

public struct LifeWikiAllPatternPage {
    let links: [URL]
    let nextLink: URL?

    public var patternLinks: [URL] {
        links.filter { !$0.isTemplateURL }
    }

    public static func fetchAll() -> AnyPublisher<[LifeWikiAllPatternPage], Never> {
        fetchToTail(url: firstPageURL)
    }

    public static func fetch(url: URL) -> AnyPublisher<LifeWikiAllPatternPage?, Never> {
        return downloader.downloadPublisher(url: url, type: .html)
            .map { html in
                LifeWikiAllPatternPage(html: html!)
            }
            .eraseToAnyPublisher()
    }
    
    public init(html: String) {
        let doc: Document = try! SwiftSoup.parse(html)
        let area = try! doc.select(".mw-category a")
        links = area.array().map {
            let href = try! $0.attr("href")
            return URL(string: "https://www.conwaylife.com\(href)")!
        }
        
        let pageLinks = try! doc.select("#mw-pages a[title='Category:Patterns']").array()
        nextLink = pageLinks
            .filter {
                try! $0.html().contains("next page")
            }
            .first
            .flatMap {
                let href = try! $0.attr("href")
                return URL(string: "https://www.conwaylife.com\(href)")
            }
    }
    
    // MARK: Internal
    
    static func fetchToTail(url: URL?) -> AnyPublisher<[LifeWikiAllPatternPage], Never> {
        guard let url = url else {
            return Just([])
                .eraseToAnyPublisher()
        }
        
        return fetch(url: url)
            .flatMap { page -> AnyPublisher<[LifeWikiAllPatternPage], Never> in
                if let page = page {
                    return Just([page])
                        .zip(fetchToTail(url: page.nextLink)) // ⤴️ recursive call
                        .map(+)
                        .eraseToAnyPublisher()
                } else {
                    return Just([])
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
