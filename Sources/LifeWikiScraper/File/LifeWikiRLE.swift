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
    public let sourceURL: URL
    
    public static func fetch(url: URL) -> AnyPublisher<LifeWikiRLE?, Never> {
        downloader.downloadPublisher(url: url, type: .plainText)
            .map { text in
                guard let text = text else {
                    print("❌ RLE is can't fetched (\(url))")
                    return nil
                }
                print("🌎 RLE fetched (\(url))")
                return LifeWikiRLE(text: text, source: url) // TODO: 暫定（エラー型を扱ったほうがよさそう）
            }
            .eraseToAnyPublisher()
    }

    // TODO: エラーに変更したい
    init?(text: String, source: URL) {
        self.sourceURL = source
        
        // Note:
        // ファイルによって改行コードが異なる事があるので、実際のファイルの内容から推定する必要がある。
        // （複数の改行コードが混在したケースもあるので、現状の処理では不十分ではある）
        let lineSeparator: Character = text.first(where: { $0 == "\r\n" || $0 == "\n" })!
        
        // Note:
        // 中には1MBを超える巨大なファイルも存在するため、メタ情報の行だけ先読みして処理が不要ならスキップする。
        // https://www.conwaylife.com/patterns/caterloopillar31c240.rle
        guard let metaLine = Self.extractMetaLine(text, lineSeparator: lineSeparator) else {
            print("⚠️ Skipped because meta line is missing. (\(source))")
            return nil
        }
        
        let meta = Self.parseMetaLines(metaLine)
        guard
            let x = meta["x"].flatMap(Int.init),
            let y = meta["y"].flatMap(Int.init) else {
            print("⏭ Parse process is skpped because board size is missing. (\(source)")
            return nil
        }

        self.x = x
        self.y = y
        rule = meta["rule"]!
        
        guard x * y < 10000 else {
            print("⏭ Parse process is skpped because size is over than 10,000. (\(x) x \(y))")
            return nil
        }
        
        let lines = text
            .split(separator: lineSeparator)
            .map(String.init)
        
        let commentLines = lines.prefix(while: { $0.hasPrefix("#") })
        //var metaLines = lines.drop(while: { $0.hasPrefix("#") })
        
        let comment = Self.parseCommentLines(commentLines)
        name = comment["N"]?.first!
        author = comment["O"]?.first
        comments = comment["C"] ?? []

        let dataLine = lines[(commentLines.count + 1)...].joined().dropLast() // remove `!`
        guard let decoded = SwiftRLE.decode(String(dataLine)) else {
            return nil
        }
        
        cells = decoded
            .split(separator: "$", omittingEmptySubsequences: false)
            .map { line in
                line.map { $0 == "o" ? 1 : 0 }.filled(to: x, by: 0)
            }
            .reduce([], +)
        
        if x * y != cells.count {
            print("RLE is invalid.")
            return nil
        }
    }
    
    // MARK: Private
    
    private static func extractMetaLine(_ text: String, lineSeparator: Character) -> String? {
        guard let range = text.range(of: "x = ") else { return nil }
        let startIndex = range.lowerBound
        let endIndex = text[startIndex...].firstIndex(where: { $0 == "\r\n" || $0 == "\n" })!
        return String(text[startIndex..<endIndex])
    }
    
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
