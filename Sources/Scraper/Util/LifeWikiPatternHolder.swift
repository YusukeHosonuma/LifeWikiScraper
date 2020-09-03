//
//  LifeWikiPatternHolder.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/03.
//

import Foundation

// TODO: ディレクトリは事前に作成しておく

public final class LifeWikiPatternHolder {
    public static func isScraped(_ sourceURL: URL) -> Bool {
        FileManager().fileExists(atPath: Self.filePath(sourceURL).path)
    }
    
    public static func write(_ pattern: LifeWikiPattern) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            let data = try encoder.encode(pattern)
            let path = Self.filePath(pattern.sourceURL)
            try data.write(to: path)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func filePath(_ sourceURL: URL) -> URL {
        URL(fileURLWithPath: "/Users/hosonumayuusuke/Downloads/Patterns/")
            .appendingPathComponent(sourceURL.lastPathComponent)
            .appendingPathExtension("json")
    }
}
