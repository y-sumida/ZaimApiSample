//
//  ProfileViewModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/28.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

class ProfileViewModel {
    let finishTrigger: PublishSubject<Void> = PublishSubject()

    private let bag = DisposeBag()
    private var model: UserVerifyModel!

    var name: String = ""
    var inputCount: Int = 0
    var dayCount: Int = 0

    func fetch(client: OAuthSwiftClient) {
        UserVerifyModel.call(client: client)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {model, response in
                    self.name = model.name
                    self.inputCount = model.inputCount
                    self.dayCount = model.dayCount
                    self.finishTrigger.onNext(())
            },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}
