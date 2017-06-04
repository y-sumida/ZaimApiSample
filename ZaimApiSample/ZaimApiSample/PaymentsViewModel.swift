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

    private var page: Int = 1

    var payments: [MoneyEditViewModel] = []

    func fetch(client: OAuthSwiftClient) {
        page = 1

        MoneyModel.call(client: client, page: page)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.payments = model.item.map { return MoneyEditViewModel(money: $0) }
                    self?.finishTrigger.onNext(())
                },
                onError: {[weak self] (error: Error) in
                    print(error.localizedDescription)
                }
            )
            .addDisposableTo(bag)
    }

    func moreFetch(client: OAuthSwiftClient) {
        page += 1

        MoneyModel.call(client: client, page: page)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.payments += model.item.map { return MoneyEditViewModel(money: $0) }
                    self?.finishTrigger.onNext(())
                },
                onError: {[weak self] (error: Error) in
                    print(error.localizedDescription)
                }
            )
            .addDisposableTo(bag)
    }

    func delete(client: OAuthSwiftClient, id: Int, mode: MoneyMode) {
        MoneyDeleteModel.call(client: client, id: id, mode: mode)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.payments = (self?.payments.filter { item in item.id != model.id })!
                    self?.finishTrigger.onNext(())
                },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            }
            )
            .addDisposableTo(bag)
    }
}

