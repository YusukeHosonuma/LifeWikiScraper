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
    case rleFetchFailed(wikiPageURL: URL, cause: Error)
}

extension ScrapeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .patternPageNotFound(wikiPageURL: let url):
            return "Wiki page is not found. (\(url))"
            
        case .rleLinkMissing(wikiPageURL: let url):
            return "RLE link is missing. (in \(url))"
            
        case let .rleFetchFailed(url, error):
            return "Fetch RLE file is failed at \(url). Cause: \(error))"
        }
    }
}
