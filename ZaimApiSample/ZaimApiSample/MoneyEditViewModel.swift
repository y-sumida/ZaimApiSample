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

    let isUpdateTrigger: PublishSubject<Void> = PublishSubject()
    let finishTrigger: PublishSubject<Void> = PublishSubject()

    private let bag = DisposeBag()
    private var original: MoneyModel.Item!

    convenience init (money: MoneyModel.Item) {
        self.init()

        original = money

        id = money.id
        mode.value = money.mode
        amount.value = money.ammount
        date.value = money.date
    }

    func updateMoney(client: OAuthSwiftClient) {
        let parameter: MoneyUpdateParam = MoneyUpdateParam(id: id!, mode: mode.value, amount: amount.value, date: date.value, categoryId: nil, genreId: nil)

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
}
