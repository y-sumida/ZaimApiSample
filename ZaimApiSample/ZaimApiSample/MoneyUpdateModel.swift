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

    var parameters: OAuthSwift.Parameters

    init(parameter: MoneyUpdateParam) {
        parameters = ["map": 1, "id": parameter.id, "amount": parameter.amount, "date": parameter.date, "category_id": parameter.categoryId.rawValue, "genreId": parameter.genreId.rawValue]
        path = "home/money/\(parameter.mode.rawValue)/\(parameter.id)"
    }
}

struct MoneyUpdateParam {
    let id: Int
    let mode: MoneyMode
    let amount: Int
    let date : String
    let categoryId: PaymentCategory
    let genreId: PaymentGenre

    init(viewModel: MoneyEditViewModel) {
        self.id = viewModel.id!
        self.mode = viewModel.mode.value
        self.amount = viewModel.amount.value
        self.date = viewModel.date.value
        self.categoryId = viewModel.categoryId.value
        self.genreId = viewModel.genreId.value
    }
}
