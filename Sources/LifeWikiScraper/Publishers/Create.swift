//
//  SomePublisher.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine

extension AnyPublisher {
    init(handler: @escaping Publishers.Create<Output, Failure>.Handler) {
        self = Publishers.Create(handler).eraseToAnyPublisher()
    }
}

extension Publishers {
    struct Create<Output, Failure: Error>: Combine.Publisher {
        typealias Handler = (Subscriber) -> Cancellable

        private let handler: Handler

        init(_ handler: @escaping Handler) {
            self.handler = handler
        }
        
        func receive<S>(subscriber: S) where S : Combine.Subscriber, S.Input == Output, S.Failure == Failure {
            let subscription = Subscription(handler, downstream: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension Publishers.Create {
    final class Subscription<Down: Combine.Subscriber>: Combine.Subscription where Down.Input == Output, Down.Failure == Failure {
        
        private let lock = NSRecursiveLock()
        private var downstream: Down?
        private var cancellable: Cancellable?
        private var demand: Subscribers.Demand = .none
        private var buffer = [Output]()
        private var completion: Subscribers.Completion<Failure>?
        
        init(_ handler: Handler, downstream: Down) {
            self.downstream = downstream
            
            let subscriber = Subscriber(onSend: { self.enqueu($0) },
                                        onComplete: { self.completion = $0; self.flush() })
            cancellable = handler(subscriber)
        }

        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer { lock.unlock() }

            self.demand += demand
            flush()
        }
        
        func cancel() {
            lock.lock()
            defer { lock.unlock() }

            guard let downStream = downstream else { return }

            cancellable?.cancel()
            downStream.receive(completion: .finished)
            
            self.downstream = nil
            self.buffer = []
        }
        
        private func enqueu(_ value: Output) {
            lock.lock()
            defer { lock.unlock() }

            self.buffer.append(value)
            self.flush()
        }
        
        private func flush() {
            lock.lock()
            defer { lock.unlock() }
            
            guard let downStream = downstream else { return }
            
            while self.demand > .none, !buffer.isEmpty {
                self.demand -= 1
                let value = buffer.removeFirst()
                let newDemand = downStream.receive(value)
                self.demand += newDemand
            }
            
            if let completion = completion, buffer.isEmpty {
                downStream.receive(completion: completion)
            }
        }
    }
    
    struct Subscriber {
        let onSend: (Output) -> Void
        let onComplete: (Subscribers.Completion<Failure>) -> Void
        
        func send(_ value: Output) {
            onSend(value)
        }
        
        func send(completion: Subscribers.Completion<Failure>) {
            onComplete(completion)
        }
    }
}
