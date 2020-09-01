//
//  CachedHTTPDownloader.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/01.
//

import Foundation
import os
import Combine
import CommonCrypto
import CryptoKit
// TODO: 本当は`Logger`を使ったほうがいい。

extension CachedHTTPTextDownloader {
    func downloadPublisher(url: URL) -> AnyPublisher<String?, Never> {
        Future<String?, Never> { promise in
            self.download(url: url) { (content) in
                promise(.success(content))
            }
        }
        .eraseToAnyPublisher()
    }
}

final class CachedHTTPTextDownloader {
    
    private let cacheDirectory: URL
    private let useMD5: Bool
    
    init(cacheDirectory: URL, useMD5: Bool = false) {
        do {
            try FileManager().createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("⚠️ Create to cache directory is failed. Cache is disabled. \(error.localizedDescription)")
        }
        self.cacheDirectory = cacheDirectory
        self.useMD5 = useMD5
    }
    
    func download(url: URL, completion: @escaping (String?) -> Void) {
        if let content = loadCache(source: url) {
            completion(content)
        } else {
            downloadFromNetwork(url: url, completion: completion)
        }
    }
    
    // MARK: Private
    
    private func downloadFromNetwork(url: URL, completion: @escaping (String?) -> Void) {
        URLSession.shared
            .dataTask(with: url) { (data: Data?, res: URLResponse?, err: Error?) in
                guard let data = data, let html = String(data: data, encoding: .utf8) else {
                    print("❌ Failed to download from network.")
                    completion(nil)
                    return
                }
                print("☁️ Loaded from network.")
                self.saveCache(source: url, content: html)
                completion(html)
            }.resume()
    }
    
    private func loadCache(source url: URL) -> String? {
        let filePath = cacheFilePath(source: url)
        
        guard FileManager().fileExists(atPath: filePath) else { return nil }
        
        // TODO: 雑・・・
        do {
            let text = try String(contentsOfFile: filePath, encoding: .utf8)
            print("☑️ Load from cache.")
            return text
        } catch {
            print("⚠️ Cache is found, but failed to load. Retry to load from network...")
            return nil
        }
    }
    
    private func saveCache(source url: URL, content: String) {
        let filePath = cacheFilePath(source: url)
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("✅ Save cahce is succeeded.")
        } catch {
            print("❌ Save cache is failed. \(error.localizedDescription)")
        }
    }
    
    private func cacheFilePath(source: URL) -> String {
        let fileName: String
        
        if useMD5 {
            fileName = source.absoluteString.md5
        } else {
            fileName = source.lastPathComponent
        }
        
        return cacheDirectory.appendingPathComponent(fileName).path
    }
}
