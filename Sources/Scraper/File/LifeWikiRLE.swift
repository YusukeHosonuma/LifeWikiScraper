//
//  LifeWikiRLE.swift
//  LifeWikiScraper
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import SwiftRLE
import Foundation
import Combine

// ref: https://www.conwaylife.com/wiki/Run_Length_Encoded
// e.g. https://www.conwaylife.com/patterns/rats.rle

private let downloader = CachedHTTPTextDownloader(cacheDirectory: URL(fileURLWithPath: "./cache/rle/"))

public struct LifeWikiRLE {
    public let x: Int
    public let y: Int
    public let rule: String
    public let name: String?      // #N
    public let author: String?    // #O
    public let comments: [String] // #C
    public let cells: [Int]
    //public let sourceURL: URL
    
    public static func fetch(url: URL) -> AnyPublisher<LifeWikiRLE?, Never> {
        downloader.downloadPublisher(url: url)
            .map { text in
                print("🌎 RLE fetched (\(url))")
                return LifeWikiRLE(text: text!) // TODO: 暫定（エラー型を扱ったほうがよさそう）
            }
            .eraseToAnyPublisher()
    }
    
    public init?(text: String) {
        // Note:
        // ファイルによって改行コードが異なる事があるので、実際のファイルの内容から推定する必要がある。
        let lineSeparator: Character = text.contains("\r\n") ? "\r\n" : "\n"
        
        let lines = text
            .split(separator: lineSeparator)
            .map(String.init)
        
        let commentLines = lines.prefix(while: { $0.hasPrefix("#") })
        var metaLines = lines.drop(while: { $0.hasPrefix("#") })
        
        let comment = Self.parseCommentLines(commentLines)
        name = comment["N"]?.first!
        author = comment["O"]?.first
        comments = comment["C"] ?? []
        
        let meta = Self.parseMetaLines(metaLines.removeFirst())
        guard
            let x = meta["x"].flatMap(Int.init),
            let y = meta["y"].flatMap(Int.init) else {
            print("⏭ Parse process is skpped because board size is missing.")
            return nil
        }

        self.x = x
        self.y = y
        rule = meta["rule"]!
        
        guard x * y < 10000 else {
            print("⏭ Parse process is skpped because size is over than 10,000. (\(x) x \(y))")
            return nil
        }
        
        let dataLine = metaLines.joined().dropLast() // remove `!`
        guard let decoded = SwiftRLE.decode(String(dataLine)) else {
            return nil
        }
        
        cells = decoded
            .split(separator: "$", omittingEmptySubsequences: false)
            .map { line in
                line.map { $0 == "o" ? 1 : 0 }.filled(to: x, by: 0)
            }
            .reduce([], +)
    }
    
    // MARK: Private
    
    private static func parseCommentLines(_ lines: ArraySlice<String>) -> [String: [String]] {
        lines
            .map { line -> (String, String) in
                let keyValue = line.split(separator: " ", maxSplits: 1)
                let key = String(keyValue.first!.dropFirst()) // remove "#"
                let val = String(keyValue.last!)
                return (key, val)
            }
            .reduce(into: [:]) { (result, keyValue) in
                let (key, val) = keyValue
                result[key, default: []].append(val)
            }
    }
    
    private static func parseMetaLines(_ line: String) -> [String: String] {
        line
            .split(separator: ",")
            .map { expr -> (String, String) in
                let keyValue = expr.split(separator: "=")
                let key = String(keyValue.first!).trimmingCharacters(in: .whitespaces)
                let val = String(keyValue.last!).trimmingCharacters(in: .whitespaces)
                return (key, val)
            }
            .reduce(into: [:]) { (result, keyAndValue) in
                let (key, val) = keyAndValue
                result[key] = val
            }
    }
}

extension LifeWikiRLE: CustomStringConvertible {
    public var description: String {
        let board = cells
            .map { $0 == 0 ? "□" : "■" }
            .group(by: x)
            .map { $0.joined(separator: " ") }
            .joined(separator: "\n")
        
        return """
        x = \(x), y = \(y)
        #N \(name ?? "-")
        #O \(author ?? "-")
        #C \(comments)

        \(board)
        """
    }
}
