import Foundation
import Scraper
import Combine

let fetchCount = 20 // 最後には全部取得するので不要になる

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
                let rlePublisher: AnyPublisher<LifeWikiRLE?, Never>

                if let url = page.rleURL {
                    rlePublisher = LifeWikiRLE.fetch(url: url)
                } else {
                    print("❌ RLE is not found (\(page.sourceURL)")
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
        print("📄 \(patterns)")
        exit(0)
    }

print("🚀 Run loop started.")
RunLoop.current.run()
