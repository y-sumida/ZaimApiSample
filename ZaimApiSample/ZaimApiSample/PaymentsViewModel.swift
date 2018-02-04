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
    private let hasNext: Variable<Bool> = Variable(true)
    let isLoading: Variable<Bool> = Variable(false)

    var observablePayments: Variable<[MoneyEditViewModel]> = Variable([])

    func fetch(client: OAuthSwiftClient, isRefresh: Bool = false) {
        if isRefresh {
            page = 1
            hasNext.value = true
            observablePayments.value.removeAll()
        }

        let fetchTrigger: PublishSubject<Void> = PublishSubject<Void>()

        fetchTrigger
            .withLatestFrom(isLoading.asObservable())
            .withLatestFrom(hasNext.asObservable()) { isLoading, hasNext in
                (isLoading: isLoading, hasNext: hasNext)
            }
            .flatMap { [unowned self] isLoading, hasNext -> Observable<(client: OAuthSwiftClient, page: Int)> in
                if !isLoading && hasNext {
                    return Observable.of((client: client, page: self.page))
                }
                else {
                    return Observable.empty()
                }
            }
            .do(onNext: { [weak self] (response, isLoading) in
                self?.isLoading.value = true
            })
            .flatMap { tuple in
                MoneyModel.call(client: tuple.client, page: tuple.page)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] response in
                    self?.observablePayments.value += response.0.money.map { return MoneyEditViewModel(money: $0) }
                    self?.hasNext.value = response.0.money.count == defaultApiPageLimit
                    self?.page += 1
                    self?.isLoading.value = false
                    self?.finishTrigger.onNext(())
                },
                onError: { [weak self] (error: Error) in
                    print(error.localizedDescription)
                    self?.isLoading.value = false
            })
            .disposed(by: bag)

        fetchTrigger.onNext(())
    }

    func delete(client: OAuthSwiftClient, id: Int, mode: MoneyMode) {
        MoneyDeleteModel.call(client: client, id: id, mode: mode)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.observablePayments.value = (self?.observablePayments.value.filter { item in item.id != model.money.id })!
                    self?.finishTrigger.onNext(())
                },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            })
            .disposed(by: bag)
    }
}

