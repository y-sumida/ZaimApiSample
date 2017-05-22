//
//  PaymentsViewModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/22.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

class PaymentsViewModel {
    let finishTrigger: PublishSubject<Void> = PublishSubject()

    private let bag = DisposeBag()
    private var model: MoneyModel!

    var payments: [MoneyEditViewModel] = []

    func fetch(client: OAuthSwiftClient) {
        MoneyModel.call(client: client)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    dump(model)
                    self?.model = model
                    self?.payments = model.item.map { return MoneyEditViewModel(money: $0) }
                    self?.finishTrigger.onNext(())
                },
                onError: {[weak self] (error: Error) in
                    print(error.localizedDescription)
                }
            )
            .addDisposableTo(bag)
    }
}

