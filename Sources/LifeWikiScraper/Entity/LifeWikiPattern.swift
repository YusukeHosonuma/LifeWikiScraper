//
//  LifeWikiPattern.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/02.
//

import Foundation
import Combine

public struct LifeWikiPattern: Codable {
    public let title: String
    public let patternType: String
    public let rule: String
    public let discoveredBy: String
    public let yearOfDiscovery: String
    public let width: Int
    public let height: Int
    public let cells: [Int]
    public let sourceURL: URL

    public static func fetch(wikiPageURL url: URL) -> AnyPublisher<LifeWikiPattern, ScrapeError> {
        if LifeWikiPatternHolder.isScraped(url) {
            return fetchFromLocal(wikiPageURL: url)
        } else {
            return fetchFromNetwork(wikiPageURL: url)
        }
    }

    private static func fetchFromLocal(wikiPageURL url: URL) -> AnyPublisher<LifeWikiPattern, ScrapeError> {
        Just<LifeWikiPattern>(LifeWikiPatternHolder.load(url))
            .setFailureType(to: ScrapeError.self)
            .eraseToAnyPublisher()
    }
    
    private static func fetchFromNetwork(wikiPageURL: URL) -> AnyPublisher<LifeWikiPattern, ScrapeError> {
        if #available(OSX 11.0, *) {
            typealias FailScrape = Fail<LifeWikiPattern, ScrapeError>
            return LifeWikiPatternPage.fetch(url: wikiPageURL)
                .flatMap { (page: LifeWikiPatternPage?) -> AnyPublisher<LifeWikiPattern, ScrapeError> in
                    guard let page = page else {
                        return FailScrape(error: .patternPageNotFound(wikiPageURL: wikiPageURL)).eraseToAnyPublisher()
                    }
                    guard let url = page.rleURL else {
                        return FailScrape(error: .rleLinkMissing(wikiPageURL: wikiPageURL)).eraseToAnyPublisher()
                    }

                    return LifeWikiRLE.fetch(url: url)
                        .map { LifeWikiPattern(page: page, rle: $0) }
                        .mapError { error in
                            ScrapeError.rleFetchFailed(wikiPageURL: url, cause: error)
                        }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
            
        } else {
            fatalError() // 💥 とりあえず落としてしまう
        }
    }

    public init(page: LifeWikiPatternPage, rle: LifeWikiRLE) {
        // From page:
        self.title           = page.title
        self.patternType     = page.patternType
        self.discoveredBy    = page.discoveredBy
        self.yearOfDiscovery = page.yearOfDiscovery
        self.sourceURL       = page.sourceURL

        // From rle:
        self.rule   = rle.rule
        self.width  = rle.x
        self.height = rle.y
        self.cells  = rle.cells
    }
}
