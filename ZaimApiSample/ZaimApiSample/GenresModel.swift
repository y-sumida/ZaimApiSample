//
//  GenresModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2018/02/14.
//  Copyright © 2018年 Yuki Sumida. All rights reserved.
//

import OAuthSwift
import RxSwift
import RealmSwift

class GenresModel: Codable {
    var genres: [Genre]

    static func call(client: OAuthSwiftClient) -> Observable<(GenresModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: GenreRequest())
    }
}

class Genre: RealmSwift.Object, Codable {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var categoryId: Int = 0
    @objc dynamic var parentGenreId: Int = 0
    @objc dynamic var active: Int = 0

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case categoryId = "category_id"
        case parentGenreId = "parent_genre_id"
        case active
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

struct GenreRequest: Requestable {
    typealias Response = GenresModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/genre"
    var parameters: OAuthSwift.Parameters = ["mapping":1]

    init() {}
}
