//
//  UserVerifyModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/17.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import ObjectMapper
import OAuthSwift
import RxSwift

class UserVerifyModel: Mappable {
    var id: String = ""
    var name: String = ""

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        id <- map["me.id"]
        name <- map["me.name"]
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
