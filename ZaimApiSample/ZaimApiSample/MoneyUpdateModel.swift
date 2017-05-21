//
//  MoneyUpdateModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import Foundation
import ObjectMapper
import OAuthSwift
import RxSwift

class MoneyUpdateModel: Mappable {
    var id: Int!
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id <- map["money.id"]
    }
    
    static func call(client: OAuthSwiftClient, parameter: MoneyUpdateParam) -> Observable<(MoneyUpdateModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: MoneyUpdateRequest(parameter: parameter))
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

struct MoneyUpdateRequest: Requestable {
    typealias Response = MoneyUpdateModel
    var method: OAuthSwiftHTTPRequest.Method = .PUT
    var path: String = ""
    
    let id: Int
    let mode: MoneyMode
    let amount: Int
    let date: String

    var parameters: OAuthSwift.Parameters {
        return ["map": 1, "id": id, "amount": amount, "date": date]
    }
    
    init(parameter: MoneyUpdateParam) {
        id = parameter.id
        mode = parameter.mode
        amount = parameter.amount
        date = parameter.date
        path = "home/money/\(mode.rawValue)/\(id)"
    }
}

struct MoneyUpdateParam {
    let id: Int
    let mode: MoneyMode
    let amount: Int
    let date : String
    let categoryId: Int?
    let genreId: Int?
}
