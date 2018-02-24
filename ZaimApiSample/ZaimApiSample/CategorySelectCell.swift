//
//  CategorySelectCell.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class CategorySelectCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!

    private var bag: DisposeBag!
    var bindValue: Variable<Genre?>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .subscribe(onNext: {[weak self] value in
                    guard let value = value else { return }
                    self?.categoryLabel.text = value.name
                })
                .disposed(by: bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        categoryLabel.text = "カテゴリ"
    }
}
