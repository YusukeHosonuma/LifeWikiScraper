//
//  SomePublisher.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/09.
//

import Foundation
import Combine

typealias Handler = (Subscribers.Sink<Int, Never>) -> Void

struct SomePublisher<S>: Combine.Publisher where S: Subscriber, S.Input == Int, S.Failure == Never {
    
    typealias Output = Int
    typealias Failure = Never
    
    let handler: Handler

    init(_ handler: @escaping Handler) {
        self.handler = handler
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = Subscription(handler, downStream: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

extension SomePublisher {
    final class Subscription<DownStream: Combine.Subscriber>: Combine.Subscription where DownStream.Input == Int, DownStream.Failure == Never {
        
        private let lock = NSRecursiveLock()
        
        var upstream: Subscribers.Sink<Int, Never>?
        var downStream: DownStream?
        let handler: Handler
        
        var demand: Subscribers.Demand = .none
        var completion: Subscribers.Completion<Never>?
        
        var buffer = [Int]()
        
        init(_ handler: @escaping Handler, downStream: DownStream) {
            self.handler = handler
            self.downStream = downStream
        }

        func request(_ demand: Subscribers.Demand) {
            lock.lock()
            defer { lock.unlock() }
            
            if upstream == nil {
                let upstream = Subscribers.Sink<DownStream.Input, DownStream.Failure>(receiveCompletion: { completion in
                    self.completion = completion
                }, receiveValue: { value in
                    self.buffer.append(value)
                })
                handler(upstream)
                self.upstream = upstream
            }
            
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
            downStream.receive(completion: .finished)
            
            self.downStream = nil
            self.buffer = []
        }
    }
}
// ⚠️ 要求なんて無視して全部流しちまうぞゴルァ！
//
//  let upstream = Subscribers.Sink<Int, Never>(receiveCompletion: { completion in
//      self.downStream?.receive(completion: completion)
//  }, receiveValue: { value in
//      _ = self.downStream?.receive(value)
//  })
//  handler(upstream)
