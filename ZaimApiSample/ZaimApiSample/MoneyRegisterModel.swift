//
//  MoneyRegisterModel.swift
//  ZaimApiSample
//
//  Created by 住田祐樹 on 2017/05/23.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import Foundation
import ObjectMapper
import OAuthSwift
import RxSwift

class MoneyRegisterModel: Codable {
    struct Money: Codable {
        var id: Int = 0
    }
    let money: Money

    static func call(client: OAuthSwiftClient, parameter: MoneyRegisterParam) -> Observable<(MoneyRegisterModel, HTTPURLResponse)> {
        return client.rx_responseObject2(request: MoneyRegisterRequest(parameter: parameter))
    }
}

struct MoneyRegisterRequest: Requestable2 {
    typealias Response = MoneyRegisterModel
    var method: OAuthSwiftHTTPRequest.Method = .POST
    var path: String = "home/money/payment"

    var parameters: OAuthSwift.Parameters

    init(parameter: MoneyRegisterParam) {
        parameters = ["map": 1, "amount": parameter.amount, "date": parameter.date, "category_id": parameter.categoryId.rawValue, "genre_id": parameter.genreId.rawValue]
    }
}

struct MoneyRegisterParam {
    let mode: MoneyMode
    let amount: Int
    let date : String
    let categoryId: PaymentCategory
    let genreId: PaymentGenre

    init(viewModel: MoneyEditViewModel) {
        self.mode = viewModel.mode.value
        self.amount = viewModel.amount.value
        self.date = viewModel.date.value
        self.categoryId = viewModel.categoryId.value!
        self.genreId = viewModel.genreId.value!
    }
}
