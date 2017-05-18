//
//  MoneyDeleteModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/19.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import ObjectMapper
import OAuthSwift
import RxSwift

class MoneyDeleteModel: Mappable {
    var id: Int!
    var modified: String = ""

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["money.id"]
        modified <- map["money.modified"]
    }

    static func call(client: OAuthSwiftClient, id: Int, mode: MoneyMode) -> Observable<(MoneyDeleteModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: MoneyDeleteRequest(id: id, mode: mode))
    }
}

struct MoneyDeleteRequest: Requestable {
    typealias Response = MoneyDeleteModel
    var method: OAuthSwiftHTTPRequest.Method = .DELETE
    var path: String = ""

    let id: Int
    let mode: MoneyMode

    init(id: Int, mode: MoneyMode) {
        self.id = id
        self.mode = mode
        path = "home/money/\(mode.rawValue)/\(id)"
    }
}
