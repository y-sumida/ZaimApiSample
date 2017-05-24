//
//  DatePickerCell.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class DatePickerCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!

    private let dateFormatter: DateFormatter = DateFormatter()

    private var bag: DisposeBag!
    var bindValue: Variable<String>! {
        didSet {
            bag = DisposeBag()
            bindValue.asObservable()
                .distinctUntilChanged()
                .subscribe(onNext: {[weak self] value in
                    if value.isEmpty {
                        self?.dateFormatter.dateFormat  = "yyyy-MM-dd"
                        self?.textField.text = self?.dateFormatter.string(from: Date())
                    }
                    else {
                        self?.textField.text = value
                    }
                })
                .disposed(by: bag)

            self.textField.rx.text
                .bind { string in
                    self.bindValue.value = string!
                }
                .addDisposableTo(bag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        textField.delegate = self

        // Doneボタン
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closePicker))
        toolbar.items = [flexible, done]
        textField.inputAccessoryView = toolbar

        // デフォルトは当日
        dateFormatter.dateFormat  = "yyyy-MM-dd"
        textField.text = dateFormatter.string(from: Date())
    }

    // UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePicker            = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        textField.inputView          = datePicker
        if let dateString: String = textField.text, let date: Date = dateFormatter.date(from: dateString) {
            datePicker.setDate(date, animated: true)
        }
        datePicker.addTarget(self, action: #selector(self.dateChanged), for: UIControlEvents.valueChanged)
    }

    func dateChanged(sender: UIDatePicker) {
        textField.text = dateFormatter.string(from: sender.date)
    }

    func closePicker() {
        textField.resignFirstResponder()
    }
}
