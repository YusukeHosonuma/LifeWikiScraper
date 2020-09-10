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
    
    public func fetchAll() -> AnyPublisher<LifeWikiAllPatternPage, Never> {
        AnyPublisher { subscriber in
            self.fetchToTail(url: LifeWikiAllPatternPage.firstPageURL, subscriber: subscriber)
            return AnyCancellable {}
        }
    }
    
    private func fetchToTail(url: URL?, subscriber: Publishers.Create<LifeWikiAllPatternPage, Never>.Subscriber) {
        guard let url = url else {
            subscriber.send(completion: .finished)
            return
        }
        
        LifeWikiAllPatternPage.fetch(url: url)
            .sink { page in
                guard let page = page else {
                    subscriber.send(completion: .finished)
                    return
                }
                
                subscriber.send(page)
                self.fetchToTail(url: page.nextLink, subscriber: subscriber) // ↩️
            }
            .store(in: &cancellables)
    }
    
//    public static func startFetchAllPages2() -> AnyPublisher<String, Never> {
//        AnyPublisher { subscriber in
//            subscriber.send("1")
//            subscriber.send("2")
//            subscriber.send("3")
//            subscriber.send("4")
//            subscriber.send("5")
//            subscriber.complete(.finished)
//            return AnyCancellable {}
//        }
//    }

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
