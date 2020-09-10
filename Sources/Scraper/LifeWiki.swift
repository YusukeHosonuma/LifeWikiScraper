//
//  LifeWiki.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/10.
//

import Foundation
import Combine

public enum LifeWiki {
    public typealias ScrapeResult = Result<LifeWikiPattern, ScrapeError>
    
    public static func scrapePatterns() -> AnyPublisher<[ScrapeResult], Never> {
        LifeWikiAllPatternPageScraper().fetchAll()
            .map(\.patternLinks)
            .flatMap { urls in
                Publishers.MergeMany(urls.map { url in
                    LifeWikiPattern.fetch(wikiPageURL: url)
                        .map { Result.success($0) }
                        .catch { Just(Result.failure($0)) }
                })
            }
            .collect()
            .eraseToAnyPublisher()
    }
}
