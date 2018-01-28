//
//  MoneyModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/18.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import OAuthSwift
import RxSwift

class MoneyModel: Codable {
    struct Money: Codable {
        var item: [Item]
    }
    let money: Money

    static func call(client: OAuthSwiftClient, page: Int = 1) -> Observable<(MoneyModel, HTTPURLResponse)> {
        return client.rx_responseObject2(request: MoneyRequest(page: page))
    }

    struct Item: Codable {
        var id: Int
        var mode: MoneyMode!
        var date: String
        var amount: Int
        var categoryId: PaymentCategory!
        var genreId: PaymentGenre!

        private enum CodingKeys: String, CodingKey {
            case id
            case mode
            case date
            case amount
            case categoryId = "category_id"
            case genreId = "genre_id"
        }
    }
}

struct MoneyRequest: Requestable {
    typealias Response = MoneyModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/money"
    var parameters: OAuthSwift.Parameters = [:]

    init(page: Int = 1) {
        parameters = ["mapping": 1, "mode": MoneyMode.payment.rawValue, "limit": defaultApiPageLimit, "page": page]
    }
}
