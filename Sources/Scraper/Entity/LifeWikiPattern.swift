//
//  LifeWikiPattern.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/02.
//

import Foundation

public struct LifeWikiPattern {
    public let title: String
    public let patternType: String
    public let rule: String
    public let discoveredBy: String
    public let yearOfDiscovery: String
    public let width: Int
    public let height: Int
    public let cells: [Int]
    public let sourceURL: URL

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
