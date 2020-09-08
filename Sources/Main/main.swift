import Foundation
import Scraper
import Combine

// TODO: 完全な並列ストリームに変更する（ファイル保存まで）

let fetchCount = 100 // 最後には全部取得するので不要になる

typealias ScrapeResult = Result<LifeWikiPattern, ScrapeError>

func scrapeLifeWikiPatterns() -> AnyPublisher<[ScrapeResult], Never> {
    LifeWikiAllPatternPage.fetchAll()
        .map { $0.map(\.patternLinks).joined() }
        .flatMap { urls in
            Publishers.MergeMany(urls.map { url in
                LifeWikiPattern.fetch(wikiPageURL: url)
                    .map { Result.success($0) }
                    .catch { Just(Result.failure($0)) }
                    .eraseToAnyPublisher()
            })
        }
        .collect()
        .eraseToAnyPublisher()
}

var cancellables: [AnyCancellable] = []

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    let start = Date()
    
    scrapeLifeWikiPatterns()
        .sink { (results: [Result<LifeWikiPattern, ScrapeError>]) in
            
            // TODO: guard let つかえばもうちょいきれいになりそう
            
            let patterns: [LifeWikiPattern] = results.compactMap {
                switch $0 {
                case .success(let pattern): return pattern
                case .failure(_): return nil
                }
            }
            
            let errors: [ScrapeError] = results.compactMap {
                switch $0 {
                case .success(_): return nil
                case .failure(let error): return error
                }
            }
            
            print("⭐ Scraping is finished. (success: \(patterns.count), fail: \(errors.count),  total: \(results.count))")
            print()
            
            print("❌ Fails:")
            for error in errors {
                switch error {
                case .patternPageNotFound:
                    print("- \(error.localizedDescription)")
                case .rleLinkMissing:
                    print("- \(error.localizedDescription)")
                case .rleNotFound:
                    print("- \(error.localizedDescription)")
                }
            }
            print()

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
