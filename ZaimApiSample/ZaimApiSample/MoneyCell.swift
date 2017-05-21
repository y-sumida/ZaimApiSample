//
//  MoneyCell.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/18.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MoneyCell: UITableViewCell {
    // TODO 費目の表示

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    private var bag: DisposeBag!
    var viewModel: MoneyEditViewModel! {
        didSet {
            bag = DisposeBag()
            viewModel.date.asObservable()
                .subscribe(onNext: {[weak self] value in
                    self?.dateLabel.text = value.description
                })
                .disposed(by: bag)

            viewModel.mode.asObservable()
                .subscribe(onNext: {[weak self] value in
                    self?.modeLabel.text = value.rawValue
                })
                .disposed(by: bag)

            viewModel.amount.asObservable()
                .subscribe(onNext: {[weak self] value in
                    self?.amountLabel.text = "￥\(value.description)"
                })
                .disposed(by: bag)
        }
    }
}
