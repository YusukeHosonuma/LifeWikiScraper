//
//  SomePublisher.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine

extension AnyPublisher {
    init(handler: @escaping SomePublisher<Output, Failure>.Handler) {
        self = SomePublisher(handler).eraseToAnyPublisher()
    }
}

struct SomePublisher<SubscriberInput, SubscriberFailure: Error>: Combine.Publisher {
    
    typealias Output = SubscriberInput
    typealias Failure = SubscriberFailure
    typealias Handler = (Subscriber<SubscriberInput, SubscriberFailure>) -> Cancellable

    private let handler: Handler

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    
    func receive<S>(subscriber: S) where S : Combine.Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(handler, downStream: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension SomePublisher {
    final class Subscription<Downstream: Combine.Subscriber>: Combine.Subscription where Downstream.Input == Output, Downstream.Failure == Failure {
        
        private let lock = NSRecursiveLock()
        private var downstream: Downstream?
        private var cancellable: Cancellable?
        private var demand: Subscribers.Demand = .none
        private var buffer = [Output]()
        private var completion: Subscribers.Completion<Failure>?
        
        init(_ handler: @escaping Handler, downStream: Downstream) {
            self.downstream = downStream
            
            let subscriber = Subscriber(onSend: { self.buffer.append($0) },
                                        onComplete: { self.completion = $0 })
            cancellable = handler(subscriber)
        }

        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer { lock.unlock() }
            
            self.demand += demand
            
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
        
        func cancel() {
            lock.lock()
            defer { lock.unlock() }

            guard let downStream = downstream else { return }

            cancellable?.cancel()
            downStream.receive(completion: .finished)
            
            self.downstream = nil
            self.buffer = []
        }
    }
    
    struct Subscriber<Input, Failure: Error> {
        let onSend: (Input) -> Void
        let onComplete: (Subscribers.Completion<Failure>) -> Void
        
        func send(_ value: Input) {
            onSend(value)
        }
        
        func complete(_ complete: Subscribers.Completion<Failure>) {
            onComplete(complete)
        }
    }
}
