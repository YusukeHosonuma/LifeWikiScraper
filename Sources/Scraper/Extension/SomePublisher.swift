//
//  SomePublisher.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine


struct SomePublisher<SubscriberInput, SubscriberFailure: Error>: Combine.Publisher {
    
    typealias Output = SubscriberInput
    typealias Failure = SubscriberFailure
    typealias Handler = (Subscriber<SubscriberInput, SubscriberFailure>) -> Cancellable

    let handler: Handler

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    
    func receive<S>(subscriber: S) where S : Combine.Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(handler, downStream: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension SomePublisher {
    final class Subscription<DownStream: Combine.Subscriber>: Combine.Subscription where DownStream.Input == Output, DownStream.Failure == Failure {
        
        private let lock = NSRecursiveLock()
        
        var cancellable: Cancellable?
        var downStream: DownStream?
        
        var demand: Subscribers.Demand = .none
        var completion: Subscribers.Completion<Failure>?
        
        var buffer = [Output]()
        
        init(_ handler: @escaping Handler, downStream: DownStream) {
            self.downStream = downStream
            
            let subscriber = Subscriber(onSend: { self.buffer.append($0) },
                                        onComplete: { self.completion = $0 })
            cancellable = handler(subscriber)
        }

        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer { lock.unlock() }
            
            self.demand += demand
            
            guard let downStream = downStream else { return }
            
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
            guard let downStream = downStream else { return }

            cancellable?.cancel()
            downStream.receive(completion: .finished)
            
            self.downStream = nil
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
