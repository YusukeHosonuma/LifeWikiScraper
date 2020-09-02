import Foundation
import Scraper
import Combine

let fetchCount = 20 // 最後には全部取得するので不要になる

// TODO: 現状よくわかっていないが、`asyncAfter`で遅延実行しないと`RunLoop`の処理に到達しない。ので暫定対処

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    
    _ = LifeWikiAllPatternPage.fetchAll()
        .flatMap { (pages: [LifeWikiAllPatternPage]) -> AnyPublisher<[LifeWikiPatternPage], Never> in
            print("⚡️ Start fetch Pattern pages.")
            let initial = Just([LifeWikiPatternPage]()).eraseToAnyPublisher()
            return pages.map(\.links).joined()
                .prefix(fetchCount)
                .reduce(initial) { (result, link) in
                    result.zip(LifeWikiPatternPage.fetch(url: link))
                        .map { $0.0 + [$0.1] }
                        .eraseToAnyPublisher()
                }
        }
        .flatMap { (pages: [LifeWikiPatternPage]) -> AnyPublisher<[(LifeWikiPatternPage, LifeWikiRLE?)], Never> in
            print("⚡️ Start fetch RLE.")
            let initial = Just([LifeWikiRLE?]()).eraseToAnyPublisher()
            return pages
                .reduce(initial) { (result, page) in
                    guard let url = page.rleURL else {
                        print("❌ RLE is not found (\(page.sourceURL)")
                        return result
                    }
                    return result.zip(LifeWikiRLE.fetch(url: url))
                        .map { $0.0 + [$0.1] }
                        .eraseToAnyPublisher()
                }
                .map { Array(zip(pages, $0)) }
                .eraseToAnyPublisher()
            
        }
        .sink { results in
            print("⭐ Found \(results.count) pages.")
            let page = results.first!.0
            let rle = results.first!.1
            print("📄 \(page)")
            print("🔖 \(rle!)")
            exit(0)
        }
}

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run()
