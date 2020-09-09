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
