//
//  URL+LifeWiki.swift
//  Scraper
//
//  Created by Yusuke Hosonuma on 2020/09/03.
//

import Foundation

extension URL {
    var isTemplateURL: Bool {
        lastPathComponent.hasPrefix("Template:")
    }
}
