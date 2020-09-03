import Foundation
import Scraper
import Combine

//let fetchCount = 1400 // 最後には全部取得するので不要になる

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    let start = Date()
    
    _ = LifeWikiAllPatternPage.fetchAll()
        .flatMap { (pages: [LifeWikiAllPatternPage]) -> AnyPublisher<[LifeWikiPatternPage], Never> in
            print("⚡️ Start fetch Pattern pages.")
            let initial = Just([LifeWikiPatternPage]()).eraseToAnyPublisher()
            return pages.map(\.patternLinks).joined()
                //.prefix(fetchCount)
                .reduce(initial) { (result, link) in
                    result.zip(LifeWikiPatternPage.fetch(url: link))
                        .map { (result: [LifeWikiPatternPage], page: LifeWikiPatternPage?) in
                            guard let page = page else { return result }
                            return result + [page]
                        }
                        .eraseToAnyPublisher()
                }
        }
        .flatMap { (pages: [LifeWikiPatternPage]) -> AnyPublisher<[(LifeWikiPatternPage, LifeWikiRLE?)], Never> in
            print("⚡️ Start fetch RLE.")
            let initial = Just([LifeWikiRLE?]()).eraseToAnyPublisher()
            return pages
                .reduce(initial) { (result, page) in
                    let rlePublisher: AnyPublisher<LifeWikiRLE?, Never>

                    if let url = page.rleURL {
                        rlePublisher = LifeWikiRLE.fetch(url: url)
                    } else {
                        print("⏭ Skipped because RLE is not found (\(page.sourceURL))")
                        rlePublisher = Just<LifeWikiRLE?>(nil).eraseToAnyPublisher()
                    }
                    
                    return result.zip(rlePublisher)
                        .map { $0.0 + [$0.1] }
                        .eraseToAnyPublisher()
                }
                .map { rles in
                    Array(zip(pages, rles))
                }
                .eraseToAnyPublisher()
        }
        .sink { results in
            let patterns = results
                .compactMap {
                    guard let rle = $0.1 else { return nil }
                    return ($0.0, rle)
                }
                .map(LifeWikiPattern.init)
            
            print("⭐ Found \(patterns.count) pages.")
            
            let elapsed = Date().timeIntervalSince(start)
            print("🌈 Finish! (\(elapsed))")

            print("📄 Patterns")
            for pattern in patterns {
                print("\(pattern)")
                print()
            }
            exit(0)
        }
}

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run(until: Date(timeInterval: 1000, since: Date()))
