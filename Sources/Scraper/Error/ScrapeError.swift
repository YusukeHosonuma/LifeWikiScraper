//
//  ScrapeError.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/08.
//

import Foundation

public enum ScrapeError: Error {
    case patternPageNotFound(wikiPageURL: URL)
    case rleLinkMissing(wikiPageURL: URL)
    case rleNotFound(url: URL)
}

extension ScrapeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .patternPageNotFound(wikiPageURL: let url):
            return "Wiki page is not found. (\(url))"
            
        case .rleLinkMissing(wikiPageURL: let url):
            return "RLE link is missing. (in \(url))"
            
        case .rleNotFound(url: let url):
            return "RLE file is not found. (\(url))"
        }
    }
}
