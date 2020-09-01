import Foundation
import Scraper
import Combine

let fetchCount = 20 // 最後には全部取得するので不要になる

// TODO: 現状よくわかっていないが、`asyncAfter`で遅延実行しないと`RunLoop`の処理に到達しない。ので暫定対処

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    
    _ = LifeWikiAllPatternPage.fetchAll()
        .flatMap {
            $0.map(\.links).joined()
                .prefix(fetchCount)
                .reduce(
                    Just([LifeWikiPatternPage]()).eraseToAnyPublisher()
                ) { (result, link) in
                    result.zip(LifeWikiPatternPage.fetch(url: link))
                        .map { $0.0 + [$0.1] }
                        .eraseToAnyPublisher()
                }
        }
        .sink { patternPages in
            print("⭐ Found \(patternPages.count) pages.")
            exit(0)
        }
}

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run()
