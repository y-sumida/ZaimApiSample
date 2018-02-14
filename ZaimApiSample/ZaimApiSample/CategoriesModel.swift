//
//  CategoriesModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2018/02/12.
//  Copyright © 2018年 Yuki Sumida. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift
import RealmSwift

class CategoriesModel: Codable {
    var categories: [Category]

    static func call(client: OAuthSwiftClient) -> Observable<(CategoriesModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: CategoryRequest())
    }

}

class Category: RealmSwift.Object, Codable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var parentCategoryId: Int = 0
    @objc dynamic var active: Int = 0
    var mode: String = ""

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case parentCategoryId = "parent_category_id"
        case active
        case mode
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

struct CategoryRequest: Requestable {
    typealias Response = CategoriesModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/category"
    var parameters: OAuthSwift.Parameters = ["mapping":1]

    init() {}
}
