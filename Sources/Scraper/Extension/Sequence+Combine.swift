//
//  Sequence+Combine.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/08.
//

import Combine

extension Sequence where Element: Publisher {
    public func waitAll() -> AnyPublisher<[Element.Output], Element.Failure> {
        let initial = Just<[Element.Output]>([])
            .setFailureType(to: Element.Failure.self)
            .eraseToAnyPublisher()
        
        return self.reduce(initial) { (result, publisher) in
            result.zip(publisher) { $0 + [$1] }.eraseToAnyPublisher()
        }
    }
}
