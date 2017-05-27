//
//  IntExtension.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/27.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation

extension Int {
    var commaSeparated: String {
        let formatter: NumberFormatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: self as NSNumber)!
    }
}
