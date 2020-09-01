//
//  XCTestCase+.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest

extension XCTestCase {
    func getData(url: URL) -> Data {
        let exp = expectation(description: "")
        
        var result: Data!
        
        URLSession.shared.dataTask(with: url) { (data: Data?, res: URLResponse?, err: Error?) in
            guard let data = data else { fatalError() }
            result = data
            exp.fulfill()
        }.resume()
        
        wait(for: [exp], timeout: 3.0)
        return result
    }
    
    func getHTML(_ urlString: String) -> String {
        let data = getData(url: URL(string: urlString)!)
        return String(data: data, encoding: .utf8)!
    }
}
