//
//  CachedHTTPDownloader.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/01.
//

import Foundation
import os

// TODO: 本当は`Logger`を使ったほうがいい。

final class CachedHTTPTextDownloader {
    
    private let cacheDirectory: URL
    
    init(cacheDirectory: URL) {
        do {
            try FileManager().createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        } catch {
            print("⚠️ Create to cache directory is failed. Cache is disabled. \(error.localizedDescription)")
        }
        self.cacheDirectory = cacheDirectory
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
            print("✅ Load from cache.")
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
        let fileName = source.lastPathComponent
        return cacheDirectory.appendingPathComponent(fileName).path
    }
}
