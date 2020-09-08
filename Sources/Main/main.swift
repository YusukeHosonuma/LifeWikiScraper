import Foundation
import Scraper
import Combine

// TODO: 完全な並列ストリームに変更する（ファイル保存まで）

let fetchCount = 100 // 最後には全部取得するので不要になる

func scrapeLifeWikiPatterns() -> AnyPublisher<[Result<LifeWikiPattern, ScrapeError>], Never> {
    LifeWikiAllPatternPage.fetchAll()
        .flatMap { (pages: [LifeWikiAllPatternPage]) -> AnyPublisher<[Result<LifeWikiPattern, ScrapeError>], Never> in
            let urls = pages.map(\.patternLinks).joined()
            let initial = Just([Result<LifeWikiPattern, ScrapeError>]()).eraseToAnyPublisher()
            return urls.reduce(initial) { result, url in
                result.zip(
                    LifeWikiPattern.fetch(wikiPageURL: url)
                        .map { pattern ->  Result<LifeWikiPattern, ScrapeError> in
                            Result<LifeWikiPattern, ScrapeError>.success(pattern)
                        }
                        .catch { error in
                            Just(Result<LifeWikiPattern, ScrapeError>.failure(error))
                        }
                        .eraseToAnyPublisher()
                ) { $0 + [$1] }
                .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
}

var cancellables: [AnyCancellable] = []

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    let start = Date()
    
    scrapeLifeWikiPatterns()
        .sink { (patterns: [Result<LifeWikiPattern, ScrapeError>]) in
            for pattern in patterns {
                switch pattern {
                case let .success(pattern):
                    print("🍎 '\(pattern.title)' is scraped.")
                
                case let .failure(error):
                    switch error {
                    case .patternPageNotFound:
                        print("🍏 ページ見つかんなかったよ。")
                    case .rleLinkMissing:
                        print("🍊 RLEリンクなかったよ。")
                    case .rleNotFound:
                        print("🍇 RLEファイル無かったよ。")
                    }
                }
            }
            print("⭐ Scraping is finished. (total: \(patterns.count))")
            
            let elapsed = Date().timeIntervalSince(start)
            print("🌈 Finish! (\(elapsed))")
            
            exit(0)
        }
        .store(in: &cancellables)
//    let start = Date()
//
//    _ = LifeWikiAllPatternPage.fetchAll()
//        .flatMap { (pages: [LifeWikiAllPatternPage]) -> AnyPublisher<[LifeWikiPatternPage], Never> in
//            print("⚡️ Start fetch Pattern pages.")
//            let initial = Just([LifeWikiPatternPage]()).eraseToAnyPublisher()
//            return pages.map(\.patternLinks).joined()
//                .prefix(fetchCount)
//                .reduce(initial) { (result, link) in
//                    result.zip(LifeWikiPatternPage.fetch(url: link))
//                        .map { (result: [LifeWikiPatternPage], page: LifeWikiPatternPage?) in
//                            guard let page = page else { return result }
//                            return result + [page]
//                        }
//                        .eraseToAnyPublisher()
//                }
//        }
//        .map { (pages: [LifeWikiPatternPage]) in
//            pages.filter {
//                let isScraped = LifeWikiPatternHolder.isScraped($0.sourceURL)
//                if isScraped {
//                    print("🌤 Skip because already scraped. (\($0.sourceURL))")
//                }
//                return !isScraped
//            }
//        }
//        .flatMap { (pages: [LifeWikiPatternPage]) -> AnyPublisher<[(LifeWikiPatternPage, LifeWikiRLE?)], Never> in
//            print("⚡️ Start fetch RLE.")
//            let initial = Just([LifeWikiRLE?]()).eraseToAnyPublisher()
//            return pages
//                .reduce(initial) { (result, page) in
//                    let rlePublisher: AnyPublisher<LifeWikiRLE?, Never>
//
//                    if let url = page.rleURL {
//                        rlePublisher = LifeWikiRLE.fetch(url: url)
//                    } else {
//                        print("⏭ Skipped because RLE is not found (\(page.sourceURL))")
//                        rlePublisher = Just<LifeWikiRLE?>(nil).eraseToAnyPublisher()
//                    }
//
//                    return result.zip(rlePublisher)
//                        .map { $0.0 + [$0.1] }
//                        .eraseToAnyPublisher()
//                }
//                .map { rles in
//                    Array(zip(pages, rles))
//                }
//                .eraseToAnyPublisher()
//        }
//        .sink { results in
//            let patterns = results
//                .compactMap {
//                    guard let rle = $0.1 else { return nil }
//                    return ($0.0, rle)
//                }
//                .map { page, rle in
//                    LifeWikiPattern(page: page, rle: rle)
//                }
//
//            print("⭐ Found \(patterns.count) pages.")
//
//            for pattern in patterns {
//                print("📁 Save \(pattern.title)...")
//                LifeWikiPatternHolder.write(pattern)
//            }
//
//            let elapsed = Date().timeIntervalSince(start)
//            print("🌈 Finish! (\(elapsed))")
//
//            exit(0)
//        }
}

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run(until: Date(timeInterval: 1000, since: Date()))
