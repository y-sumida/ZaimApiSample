//
//  MoneyModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/18.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import ObjectMapper
import OAuthSwift
import RxSwift

class MoneyModel: Mappable {
    var item: [Item] = []

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        item <- map["money"]
    }

    static func call(client: OAuthSwiftClient) -> Observable<(MoneyModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: MoneyRequest())
    }

    class Item: Mappable {
        var id: Int!
        var mode: MoneyMode!
        var date: String = ""
        var ammount: Int = 0

        required convenience init?(map: Map) {
            self.init()
        }

        func mapping(map: Map) {
            id <- map["id"]
            mode <- map["mode"]
            date <- map["date"]
            ammount <- map["amount"]
        }
    }
}

struct MoneyRequest: Requestable {
    typealias Response = MoneyModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/money"

    init() {}
}
