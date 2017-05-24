//
//  GenresViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/22.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class GenresViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    private let bag: DisposeBag = DisposeBag()

    var categoryId: Variable<PaymentCategory?>!
    var genreId: Variable<PaymentGenre?>! {
        didSet {
            genreId.asObservable()
                .subscribe(onNext: {[weak self] value in
                    // 選択されたらenable
                    self?.doneButton.isEnabled = true
                })
                .disposed(by: bag)
        }
    }

    deinit {
        print("Genres deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "ジャンル"
            navigationItem.hidesBackButton = false
        }

        // 完了ボタンdisable
        doneButton.isEnabled = false

        tableView.delegate = self
        tableView.dataSource = self
        let categoryNib = UINib(nibName: "GenreSelectCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "GenreSelectCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapDoneButton(_ sender: Any) {
        categoryId.value = genreId.value?.parentCategory
        self.dismiss(animated: true, completion: nil)
    }
}

extension GenresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        genreId.value = (paymentGenres[categoryId.value!]?[indexPath.row])!
    }
}

extension GenresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentGenres[categoryId.value!]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GenreSelectCell = tableView.dequeueReusableCell(withIdentifier: "GenreSelectCell") as! GenreSelectCell
        cell.genreLabel.text = paymentGenres[categoryId.value!]?[indexPath.row].description
        return cell
    }
}
