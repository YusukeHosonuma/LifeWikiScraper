import Foundation
import Scraper
import Combine

// TODO: 完全な並列ストリームに変更する（ファイル保存まで）

let fetchCount = 100 // 最後には全部取得するので不要になる

var cancellables: [AnyCancellable] = []

typealias ScrapeResult = Result<LifeWikiPattern, ScrapeError>

func executeParallelScraper() {
    let startTime = Date()
    
    let scraper = LifeWikiAllPatternPageScraper()
    scraper.fetchPageSubject
        .map(\.patternLinks)
        .flatMap { urls in
            Publishers.MergeMany(urls.map { url in
                LifeWikiPattern.fetch(wikiPageURL: url)
                    .map { Result.success($0) }
                    .catch { Just(Result.failure($0)) }
                    .eraseToAnyPublisher()
            })
        }
        .collect()
        .sink { results in
            outputReport(results: results, startTime: startTime)
        }
        .store(in: &cancellables)
    scraper.startFetchAllPages()
}

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

func outputReport(results: [ScrapeResult], startTime: Date) {
    let patterns: [LifeWikiPattern] = results.compactMap {
        guard case .success(let pattern) = $0 else { return nil }
        return pattern
    }
    
    let errors: [ScrapeError] = results.compactMap {
        guard case .failure(let error) = $0 else { return nil }
        return error
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

    let elapsed = Date().timeIntervalSince(startTime)
    print("🌈 Finish! (\(elapsed))")
}

/*
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    executeParallelScraper()
    return

//    scrapeLifeWikiPatterns()
//        .sink { (results: [Result<LifeWikiPattern, ScrapeError>]) in
//
//            // TODO: guard let つかえばもうちょいきれいになりそう
//
//            let patterns: [LifeWikiPattern] = results.compactMap {
//                switch $0 {
//                case .success(let pattern): return pattern
//                case .failure(_): return nil
//                }
//            }
//
//            let errors: [ScrapeError] = results.compactMap {
//                switch $0 {
//                case .success(_): return nil
//                case .failure(let error): return error
//                }
//            }
//
//            print("⭐ Scraping is finished. (success: \(patterns.count), fail: \(errors.count),  total: \(results.count))")
//            print()
//
//            print("❌ Fails:")
//            for error in errors {
//                switch error {
//                case .patternPageNotFound:
//                    print("- \(error.localizedDescription)")
//                case .rleLinkMissing:
//                    print("- \(error.localizedDescription)")
//                case .rleNotFound:
//                    print("- \(error.localizedDescription)")
//                }
//            }
//            print()
//
//            let elapsed = Date().timeIntervalSince(start)
//            print("🌈 Finish! (\(elapsed))")
//
//            exit(0)
//        }
//        .store(in: &cancellables)
}
 */

LifeWikiAllPatternPageScraper.startFetchAllPages2()
    .flatMap(maxPublishers: .max(2)) { value -> Future<String, Never> in
        print("🍏 \(value)")
        return Future<String, Never> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                promise(.success(value))
            }
        }
    }
    .sink { completion in
        print("⭐ \(completion)")
    } receiveValue: { value in
        print("🍊 \(value)")
    }
    .store(in: &cancellables)

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run(until: Date(timeInterval: 1000, since: Date()))
