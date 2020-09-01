//
//  LifeWikiRLETests.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
@testable import Scraper
import SwiftRLE

final class LifeWikiRLETests: XCTestCase {
    
    // http://conwaylife.com/patterns/hook.rle
    func testExample() throws {
        do {
            let result = LifeWikiRLE(text: """
            #N Hook
            #O Unknown
            #C http://conwaylife.com/wiki/Hook
            #C http://conwaylife.com/patterns/hook.rle
            x = 3, y = 2, rule = B3/S23
            obo$b2o!
            """)

            let rle = try XCTUnwrap(result)
            XCTAssertEqual(rle.name, "Hook")
            XCTAssertEqual(rle.x, 3)
            XCTAssertEqual(rle.y, 2)
            XCTAssertEqual(rle.rule, "B3/S23")
            XCTAssertEqual(rle.cells, [
                1, 0, 1,
                0, 1, 1,
            ])
        }
    }
    
    // https://www.conwaylife.com/patterns/1234.rle
    func testExample2() throws {
        let result = LifeWikiRLE(text: """
            #N 1-2-3-4
            #C A period 4 oscillator.
            #C www.conwaylife.com/wiki/index.php?title=1-2-3-4
            x = 11, y = 11, rule = B3/S23
            5bo5b$4bobo4b$3bobobo3b$3bo3bo3b$2obobobob2o$obo5bobo$3b5o3b2$5bo5b$4b
            obo4b$5bo!
            """)
        
        let rle = try XCTUnwrap(result)
        XCTAssertEqual(rle.name, "1-2-3-4")
        XCTAssertEqual(rle.x, 11)
        XCTAssertEqual(rle.y, 11)
        XCTAssertEqual(rle.rule, "B3/S23")
        
        // https://www.conwaylife.com/patterns/1234.cells
        assertCells(rle.cells, size: 11, expectPlainText: """
            .....O
            ....O.O
            ...O.O.O
            ...O...O
            OO.O.O.O.OO
            O.O.....O.O
            ...OOOOO
            
            .....O
            ....O.O
            .....O
            """)
    }
    
    // https://www.conwaylife.com/patterns/24cellquadraticgrowth.rle
    func testExample3() throws {
        
        let result = LifeWikiRLE(text: """
        #N 24-cell quadratic growth
        #O Michael Simkin
        #C It had been the smallest known pattern, that exhibits quadratic population
        #C growth, before it was superseded by switch engine ping-pong.
        #C www.conwaylife.com/wiki/24-cell_quadratic_growth
        x = 39786, y = 143, rule = B3/S23
        39782bo$39782bo$39783b2o$39785bo$39785bo$39738bo46bo$39739bo45bo$
        39740bo$39739bo$39738bo$39740b3o101$2o$o28$19bo$18b3o$20bo!
        """)
        
        let rle = try XCTUnwrap(result)
        XCTAssertEqual(rle.name, "24-cell quadratic growth")
        XCTAssertEqual(rle.x, 39786)
        XCTAssertEqual(rle.y, 143)
        XCTAssertEqual(rle.rule, "B3/S23")
    }
    
    // MARK: Private
    
    private func assertCells(_ cells: [Int], size: Int, expectPlainText: String) {
        let actualPlainText = cells
            .map { $0 == 0 ? "." : "O" }
            .group(by: size)
            .map { $0.joined(separator: "") }
            .map {
                let removeCount = $0.reversed().prefix(while: { $0 == "." }).count
                return String($0.prefix($0.count - removeCount))
            }
            .joined(separator: "\n")
        
        XCTAssertEqual(expectPlainText, actualPlainText)
    }
}
