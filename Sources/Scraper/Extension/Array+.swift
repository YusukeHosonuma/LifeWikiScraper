//
//  Array+.swift
//  LifeWikiScraper
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

extension Array {
    func filled(to size: Int, by element: Element) -> [Element] {
        guard count < size else { return self }
        var xs = self
        xs.append(contentsOf: Array(repeating: element, count: size - count))
        return xs
    }
    
    func group(by size: Int) -> [[Element]] {
        assert(size > 0)
        
        var offset: Int = 0
        var result: [[Element]] = []
        while offset < count {
            let endIndex = Swift.min(offset + size, self.count)
            result.append(Array(self[offset..<endIndex]))
            offset += size
        }
        return result
    }
}

