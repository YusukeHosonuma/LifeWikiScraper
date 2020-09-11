import Foundation
import LifeWikiScraper
import Combine

var cancellables: [AnyCancellable] = []

func main() {
    let startTime = Date()
    LifeWiki.scrapePatterns()
        .collect()
        .sink { results in
            outputReport(results: results, startTime: startTime)
            exit(0) // 🚫
        }
        .store(in: &cancellables)
}

func outputReport(results: [LifeWiki.ScrapeResult], startTime: Date) {
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
        case .rleFetchFailed:
            print("- \(error.localizedDescription)")
        }
    }
    print()

    let elapsed = Date().timeIntervalSince(startTime)
    print("🌈 Finish! (\(elapsed))")
}

print("🚀 Start scraping.")
main()

print("🔄 Run loop started.")
RunLoop.current.run(until: Date(timeInterval: 1000, since: Date()))
