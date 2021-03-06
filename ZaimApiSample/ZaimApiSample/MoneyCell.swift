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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!

    private var bag: DisposeBag!
    var viewModel: MoneyEditViewModel! {
        didSet {
            bag = DisposeBag()
            viewModel.date.asObservable()
                .subscribe(onNext: {[weak self] value in
                    self?.dateLabel.text = String(value[value.index(value.endIndex, offsetBy: -5)...])
                })
                .disposed(by: bag)

            viewModel.genreId.asObservable()
                .subscribe(onNext: {[weak self] value in
                    self?.genreLabel.text = value?.name
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
