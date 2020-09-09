//
//  LifeWikiAllPatternPageScraper.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine

public final class LifeWikiAllPatternPageScraper {
    public lazy var fetchPageSubject: AnyPublisher<LifeWikiAllPatternPage, Never> = _fetchPageSubject.eraseToAnyPublisher()
    
    private lazy var _fetchPageSubject = PassthroughSubject<LifeWikiAllPatternPage, Never>()
    private var cancellables: [AnyCancellable] = []
    
    public init() {}
    
    public func startFetchAllPages() {
        fetchToTailPage(url: LifeWikiAllPatternPage.firstPageURL)
    }
    
    public static func startFetchAllPages2() -> AnyPublisher<String, Never> {
        SomePublisher { subscriber in
            print("🍎 Start")
            // これは冗長なのでなんとかしたい
            _ = subscriber.receive("1")
            _ = subscriber.receive("2")
            _ = subscriber.receive("3")
            _ = subscriber.receive("4")
            _ = subscriber.receive("5")
            subscriber.receive(completion: .finished)
        }
        .eraseToAnyPublisher()
    }

    private func fetchToTailPage(url: URL?) {
        guard let url = url else {
            _fetchPageSubject.send(completion: .finished)
            return
        }
        
        LifeWikiAllPatternPage.fetch(url: url)
            .sink { page in
                guard let page = page else {
                    self._fetchPageSubject.send(completion: .finished)
                    return
                }
                
                self._fetchPageSubject.send(page)
                self.fetchToTailPage(url: page.nextLink)
            }
            .store(in: &cancellables)
    }
}
