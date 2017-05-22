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
    var categoryId: Variable<PaymentCategory>!
    var genreId: Variable<PaymentGenre>!

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
        categoryId = Variable(money.categoryId)
        genreId = Variable(money.genreId)
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
}
