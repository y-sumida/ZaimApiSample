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
    var bindValue: Variable<PaymentGenre?>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .subscribe(onNext: {[weak self] value in
                    guard let _ = value else { return }
                    self?.categoryLabel.text = value?.description
                })
                .disposed(by: bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        categoryLabel.text = "カテゴリ"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
}
