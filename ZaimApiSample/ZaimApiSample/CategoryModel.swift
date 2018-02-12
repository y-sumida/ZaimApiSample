//
//  CategoryModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2018/02/12.
//  Copyright © 2018年 Yuki Sumida. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

class CategoriesModel: Codable {
    var categories: [Category]

    static func call(client: OAuthSwiftClient) -> Observable<(CategoriesModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: CategoryRequest())
    }

    class Category: Codable {
        var id: Int
        var name: String
        var parentCategoryId: Int
        var active: Int

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case parentCategoryId = "parent_category_id"
            case active
        }
    }
}

struct CategoryRequest: Requestable {
    typealias Response = CategoriesModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/category"
    var parameters: OAuthSwift.Parameters = ["mapping":1]

    init() {}
}
