//
//  MoneyEditViewModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

class MoneyEditViewModel {
    var id: Int?
    var mode: Variable<MoneyMode> = Variable(.payment)
    var amount: Variable<Int> = Variable(0)
    var date: Variable<String> = Variable("")
    var categoryId: Variable<PaymentCategory?>!
    var genreId: Variable<PaymentGenre?>!

    let isUpdate: Variable<Bool> = Variable(false)
    let finishTrigger: PublishSubject<Void> = PublishSubject()

    private let bag = DisposeBag()
    private var original: MoneyModel.Item!

    convenience init (money: MoneyModel.Item? = nil) {
        self.init()

        if let `money`: MoneyModel.Item = money {
            original = money

            id = money.id
            mode.value = money.mode
            amount.value = money.ammount
            date.value = money.date
            categoryId = Variable(money.categoryId)
            genreId = Variable(money.genreId)
        }
        else {
            categoryId = Variable(nil)
            genreId = Variable(nil)
        }

        bind()
    }

    func registerMoney(client: OAuthSwiftClient) {
        // TODO 登録処理
    }

    func updateMoney(client: OAuthSwiftClient) {
        let parameter: MoneyUpdateParam = MoneyUpdateParam(viewModel: self)

        MoneyUpdateModel.call(client: client, parameter: parameter)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: {[weak self] model, response in
                    self?.finishTrigger.onNext(())
                },
                onError: {(error: Error) in
                    print(error.localizedDescription)
            }
            )
            .addDisposableTo(bag)
    }

    private func bind() {
        // 更新有無の監視
        Observable.combineLatest(
            mode.asObservable(),
            amount.asObservable(),
            date.asObservable(),
            categoryId.asObservable(),
            genreId.asObservable())
            .bind(onNext: {[weak self] (mode, amount, date, category, genre) -> Void in
                if self?.original == nil {
                    self?.isUpdate.value = category != nil && genre != nil
                }
                else {
                    self?.isUpdate.value = (mode != self?.original.mode || amount != self?.original.ammount || date != self?.original.date || category != self?.original.categoryId || genre != self?.original.genreId)
                }
            })
            .disposed(by: bag)
    }
}