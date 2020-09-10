//
//  LifeWikiAllPatternPageScraper.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine

public final class LifeWikiAllPatternPageScraper {
    private var cancellables: [AnyCancellable] = []
    
    public init() {}

    public func fetchAll() -> AnyPublisher<LifeWikiAllPatternPage, Never> {
        AnyPublisher { subscriber in
            self.fetchToTail(url: LifeWikiAllPatternPage.firstPageURL, subscriber: subscriber)
            return AnyCancellable {}
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchToTail(url: URL?, subscriber: Publishers.Create<LifeWikiAllPatternPage, Never>.Subscriber) {
        guard let url = url else {
            subscriber.send(completion: .finished)
            return
        }
        
        DispatchQueue.global().async {
            LifeWikiAllPatternPage.fetch(url: url)
                .sink { page in
                    guard let page = page else {
                        subscriber.send(completion: .finished)
                        return
                    }
                    
                    subscriber.send(page)
                    self.fetchToTail(url: page.nextLink, subscriber: subscriber) // ↩️
                }
                .store(in: &self.cancellables)
        }
    }
}
