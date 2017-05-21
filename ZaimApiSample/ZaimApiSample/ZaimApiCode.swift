
//
//  ZaimCode.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/20.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

enum MoneyMode: String {
    case income = "income"
    case payment = "payment"
}

enum PaymentCategories : Int {
    case food = 101
    case dailyGoods = 102
    case transport = 103
    case phoneNet = 104
    case utilities = 105
    case home = 106
    case socializing = 107
    case hobbies = 108
    case education = 109
    case medical = 110
    case fashion = 111
    case automobile = 112
    case taxes = 113
    case bigOutlay = 114
    case other = 199

    var description: String {
        switch self {
        case .food: return "食費"
        case .dailyGoods: return "日用雑貨"
        case .transport: return "交通"
        case .phoneNet: return "通信"
        case .utilities: return "水道・光熱"
        case .home: return "住まい"
        case .socializing: return "交際"
        case .hobbies: return "エンタメ"
        case .education: return "教育"
        case .medical: return "医療"
        case .fashion: return "美容・衣服"
        case .automobile: return "車"
        case .taxes: return "税金"
        case .bigOutlay: return "大型出費"
        case .other: return "その他"
        }
    }
}
