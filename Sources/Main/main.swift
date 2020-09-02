import Foundation
import Scraper
import Combine

let fetchCount = 200 // 最後には全部取得するので不要になる

// TODO: 現状よくわかっていないが、`asyncAfter`で遅延実行しないと`RunLoop`の処理に到達しない。ので暫定対処

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    
    _ = LifeWikiAllPatternPage.fetchAll()
        .flatMap { (pages: [LifeWikiAllPatternPage]) -> AnyPublisher<[LifeWikiPatternPage], Never> in
            print("⚡️ Start fetch Pattern pages.")
            return pages.map(\.links).joined()
                .prefix(fetchCount)
                .reduce(
                    Just([LifeWikiPatternPage]()).eraseToAnyPublisher()
                ) { (result, link) in
                    result.zip(LifeWikiPatternPage.fetch(url: link))
                        .map { $0.0 + [$0.1] }
                        .eraseToAnyPublisher()
                }
        }
        .flatMap { (pages: [LifeWikiPatternPage]) -> AnyPublisher<[LifeWikiRLE?], Never> in
            print("⚡️ Start fetch RLE.")
            return pages
                .reduce(
                    Just([LifeWikiRLE?]()).eraseToAnyPublisher()
                ) { (result, page) in
                    if let url = page.rleURL {
                        return result.zip(LifeWikiRLE.fetch(url: url))
                            .map {
                                $0.0 + [$0.1]
                            }
                            .eraseToAnyPublisher()
                    } else {
                        print("❌ RLE is not found (\(page)") // TODO: source URL を出力するように
                        return result
                    }
                }
        }
        .sink { rles in
            print("⭐ Found \(rles.count) pages.")
            print(rles)
            exit(0)
        }
}

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run()
