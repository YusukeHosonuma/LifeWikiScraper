import Foundation
import Scraper

let cancel = LifeWikiAllPatternPage.fetchAll()
    .map {
        $0.map(\.links).joined()
    }
    .sink { pages in
        print("🍎 Found pattern pages \(pages.count) pages.")
        exit(0)
    }

let customMode = "LifeGameScraper"
RunLoop.current.run(mode: RunLoop.Mode(customMode), before: Date.distantFuture)

print("🚀 Run loop started.")
RunLoop.current.run()
