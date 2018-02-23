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

    private enum MeKeys: String, CodingKey {
        case me
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: MeKeys.self)
        let me = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .me)
        id = try me.decode(Int.self, forKey: .id)
        name = try me.decode(String.self, forKey: .name)
        inputCount = try me.decode(Int.self, forKey: .inputCount)
        dayCount = try me.decode(Int.self, forKey: .dayCount)
    }

    static func call(client: OAuthSwiftClient) -> Observable<(UserVerifyModel, HTTPURLResponse)> {
        return client.rx_responseObject(request: UserVerifyRequest())
    }
}

struct UserVerifyRequest: Requestable {
    typealias Response = UserVerifyModel
    var method: OAuthSwiftHTTPRequest.Method = .GET
    var path: String = "home/user/verify"

    init() {}
}
