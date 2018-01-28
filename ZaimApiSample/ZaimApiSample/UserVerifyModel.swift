//
//  UserVerifyModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/17.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import OAuthSwift
import RxSwift

class UserVerifyModel: Codable {
    struct Me: Codable {
        var id: Int = 0
        var name: String = ""
        var inputCount: Int = 0
        var dayCount: Int = 0

        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case inputCount = "input_count"
            case dayCount = "day_count"
        }
    }
    let me: Me

    static func call(client: OAuthSwiftClient) -> Observable<(UserVerifyModel, HTTPURLResponse)> {
        return client.rx_responseObject2(request: UserVerifyRequest())
    }
}

struct UserVerifyRequest: Requestable2 {
    typealias Response = UserVerifyModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/user/verify"

    init() {}
}
