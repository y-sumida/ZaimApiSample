//
//  MoneyUpdateModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import OAuthSwift
import RxSwift

class MoneyUpdateModel: Codable {
    struct Money: Codable {
        var id: Int = 0
    }
    let money: Money

    static func call(client: OAuthSwiftClient, parameter: MoneyUpdateParam) -> Observable<(MoneyUpdateModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: MoneyUpdateRequest(parameter: parameter))
    }
}

struct MoneyUpdateRequest: Requestable {
    typealias Response = MoneyUpdateModel
    var method: OAuthSwiftHTTPRequest.Method = .PUT
    var path: String = ""

    var parameters: OAuthSwift.Parameters

    init(parameter: MoneyUpdateParam) {
        parameters = ["map": 1, "id": parameter.id, "amount": parameter.amount, "date": parameter.date, "category_id": parameter.categoryId.rawValue, "genre_id": parameter.genreId]
        path = "home/money/\(parameter.mode.rawValue)/\(parameter.id)"
    }
}

struct MoneyUpdateParam {
    let id: Int
    let mode: MoneyMode
    let amount: Int
    let date : String
    let categoryId: PaymentCategory
    let genreId: Int

    init(viewModel: MoneyEditViewModel) {
        self.id = viewModel.id!
        self.mode = viewModel.mode.value
        self.amount = viewModel.amount.value
        self.date = viewModel.date.value
        self.categoryId = viewModel.categoryId.value!
        self.genreId = viewModel.genreId.value?.id ?? 0
    }
}
