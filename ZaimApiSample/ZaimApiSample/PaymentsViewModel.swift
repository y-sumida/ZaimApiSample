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
    private var hasNext: Bool = true

    var observablePayments: Variable<[MoneyEditViewModel]> = Variable([])

    func fetch(client: OAuthSwiftClient, isRefresh: Bool = false) {
        if isRefresh {
            page = 1
            hasNext = true
            observablePayments.value.removeAll()
        }

        guard hasNext else { return }

        MoneyModel.call(client: client, page: page)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.observablePayments.value += model.item.map { return MoneyEditViewModel(money: $0) }
                    if model.item.count < defaultApiPageLimit {
                        self?.hasNext = false
                    }
                    self?.page += 1
                    self?.finishTrigger.onNext(())
                },
                onError: {[weak self] (error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
    }

    func delete(client: OAuthSwiftClient, id: Int, mode: MoneyMode) {
        MoneyDeleteModel.call(client: client, id: id, mode: mode)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.observablePayments.value = (self?.observablePayments.value.filter { item in item.id != model.id })!
                    self?.finishTrigger.onNext(())
                },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}

