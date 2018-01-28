//
//  OAuthSwift+ObjectMapper+RxSwift.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/17.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import OAuthSwift
import RxSwift

extension OAuthSwiftClient {

    func rx_responseObject2<T: Requestable>(request: T) -> Observable<(T.Response, HTTPURLResponse)> {
        showRequestLog(request: request)

        // TODO エラー処理
        return Observable.create { (observer: AnyObserver<(T.Response, HTTPURLResponse)>) -> Disposable in
            let handle: OAuthSwiftRequestHandle?  = self.request(
                "\(request.baseURL)\(request.path)",
                method: request.method,
                parameters: request.parameters,
                success: { response in
                    self.showResponseLog(response: response)
                    let jsonDecoder = JSONDecoder()
                    let model: T.Response = try! jsonDecoder.decode(T.Response.self, from: response.data)
                    observer.onNext((model, response.response))
                    observer.on(.completed)
            },
                failure: { error in
                    observer.onError(error)
            }
            )

            return Disposables.create {
                handle?.cancel()
            }
        }
    }

    private func showRequestLog<T: Requestable>(request: T) {
        print("REQUEST--------------------")
        print("url \(request.baseURL)/\(request.path))")
        print("method \(request.method.rawValue)")
        print("parameters \(request.parameters)")
        print("---------------------------")
    }

    private func showResponseLog(response: OAuthSwiftResponse) {
        print("RESPONSE--------------------")
        if let url: String = response.request?.url?.absoluteString {
            print("url \(url)")
        }
        print("status \(response.response.statusCode)")
        if let data: String = response.dataString() {
            print("data \(data)")
        }
        print("---------------------------")
    }
    
}
