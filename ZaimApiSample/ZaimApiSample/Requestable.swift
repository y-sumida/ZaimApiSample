//
//  Requestable.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/17.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import OAuthSwift

// Temporary for ObjectMapper to Codable
protocol Requestable2 {
    associatedtype Response: Codable
    var baseURL: String { get }
    var path: String { get }
    var method: OAuthSwiftHTTPRequest.Method { get }
    var parameters: OAuthSwift.Parameters { get }
}

extension Requestable2 {
    var baseURL: String {
        return "https://api.zaim.net/v2/"
    }

    var path: String {
        return ""
    }

    var method: OAuthSwiftHTTPRequest.Method {
        return .GET
    }

    var parameters: OAuthSwift.Parameters {
        return [:]
    }
}
