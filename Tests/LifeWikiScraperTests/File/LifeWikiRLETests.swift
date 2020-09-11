//
//  LifeWikiRLETests.swift
//  LifeWikiScraperTests
//
//  Created by Yusuke Hosonuma on 2020/08/31.
//

import XCTest
@testable import LifeWikiScraper
import SwiftRLE

final class LifeWikiRLETests: XCTestCase {
    
    // http://conwaylife.com/patterns/hook.rle
    func testExample() throws {
        do {
            let result = LifeWikiRLE(
                text: """
                #N Hook
                #O Unknown
                #C http://conwaylife.com/wiki/Hook
                #C http://conwaylife.com/patterns/hook.rle
                x = 3, y = 2, rule = B3/S23
                obo$b2o!
                """,
                source: URL(string: "http://conwaylife.com/patterns/hook.rle")!
            )

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
        let result = LifeWikiRLE(
            text: """
            #N 1-2-3-4
            #C A period 4 oscillator.
            #C www.conwaylife.com/wiki/index.php?title=1-2-3-4
            x = 11, y = 11, rule = B3/S23
            5bo5b$4bobo4b$3bobobo3b$3bo3bo3b$2obobobob2o$obo5bobo$3b5o3b2$5bo5b$4b
            obo4b$5bo!
            """,
            source: URL(string: "https://www.conwaylife.com/patterns/1234.rle")!
        )
        
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
        
        let result = LifeWikiRLE(
            text: """
            #N 24-cell quadratic growth
            #O Michael Simkin
            #C It had been the smallest known pattern, that exhibits quadratic population
            #C growth, before it was superseded by switch engine ping-pong.
            #C www.conwaylife.com/wiki/24-cell_quadratic_growth
            x = 39786, y = 143, rule = B3/S23
            39782bo$39782bo$39783b2o$39785bo$39785bo$39738bo46bo$39739bo45bo$
            39740bo$39739bo$39738bo$39740b3o101$2o$o28$19bo$18b3o$20bo!
            """,
            source: URL(string: "https://www.conwaylife.com/patterns/24cellquadraticgrowth.rle")!
        )
        
        XCTAssertNil(result)
        
        // TODO: エラー型を返すように
        
//        let rle = try XCTUnwrap(result)
//        XCTAssertEqual(rle.name, "24-cell quadratic growth")
//        XCTAssertEqual(rle.x, 39786)
//        XCTAssertEqual(rle.y, 143)
//        XCTAssertEqual(rle.rule, "B3/S23")
    }
    
    // 1MB+
    func testExample4() {
        let url = URL(string: "https://www.conwaylife.com/patterns/caterloopillar31c240.rle")!
        let text = getContent(url: url, type: .plainText)
        let rle = LifeWikiRLE(text: text, source: url)
        XCTAssertNil(rle)
    }
    
    // 改行コード混在（\n + \r\n）
    func testExample5() {
        let url = URL(string: "https://www.conwaylife.com/patterns/p448dartgun.rle")!
        let text = getContent(url: url, type: .plainText)
        let rle = LifeWikiRLE(text: text, source: url)
        XCTAssertNil(rle)
    }
    
    // コメント行なし
    // https://www.conwaylife.com/patterns/258p3.rle
    func testExample6() throws {
        let result = LifeWikiRLE(
            text: """
            x = 28, y = 25, rule = B3/S23
            3bo3bobob6obobo3bo$2bob2obo2bobo2bobo2bob2obo$2bo7b2o4b2o7bo$b2o2bo3bo
            2b4o2bo3bo2b2o$o2b6ob2o4b2ob6o2bo$2o6b2ob6ob2o6b2o$2b2obo16bob2o$2o2bo
            8b2o8bo2b2o$bobo2b3o3bo2bo3b3o2bobo$o2b3o5b2o2b2o5b3o2bo$b2o3bob2obo4b
            ob2obo3b2o$2bobo2bob3o4b3obo2bobo$2bob2obo3b6o3bob2obo$b2o2bobobobo4bo
            bobobo2b2o$o2bo7b6o7bo2bo$b2o3bo14bo3b2o$5bo3b4o2b4o3bo$4bob2obo2bo2bo
            2bob2obo$4bo2b3o8b3o2bo$b2obo2b3o2bo2bo2b3o2bob2o$b2obob2o4b4o4b2obob
            2o$5bo3bo8bo3bo$6bobo10bobo$4bobobobo6bobobobo$4b2o3b2o6b2o3b2o!
            """,
            source: URL(string: "https://www.conwaylife.com/patterns/258p3.rle")!
        )
        
        let rle = try XCTUnwrap(result)
        XCTAssertNil(rle.name)
        XCTAssertEqual(rle.x, 28)
        XCTAssertEqual(rle.y, 25)
        XCTAssertEqual(rle.rule, "B3/S23")
    }

    // メタデータに記載されたサイズ（x, y）とパターンのサイズが不一致
    func testExample7() throws {
        let result = LifeWikiRLE(
            text: """
            x = 3, y = 1, rule = B2c3c/S
            obo$bbb$bbo!
            """,
            source: URL(string: "https://www.conwaylife.com/patterns/pole3rotor.rle")!
        )
        XCTAssertNil(result)
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
