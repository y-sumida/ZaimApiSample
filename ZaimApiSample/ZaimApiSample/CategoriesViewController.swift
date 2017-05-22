//
//  CategoriesViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit
import RxSwift

class CategoriesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var originarlCategoryId: PaymentCategory!
    var categoryId: Variable<PaymentCategory>! {
        didSet {
            originarlCategoryId = categoryId.value
        }
    }
    var genreId: Variable<PaymentGenre>!

    fileprivate let categories: [PaymentCategory] = [
    .food,
    .dailyGoods,
    .transport,
    .phoneNet,
    .utilities,
    .home,
    .socializing,
    .hobbies,
    .education,
    .medical,
    .fashion,
    .automobile,
    .taxes,
    .bigOutlay,
    .other
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "カテゴリー"
            navigationItem.hidesBackButton = false
        }

        tableView.delegate = self
        tableView.dataSource = self
        let categoryNib = UINib(nibName: "CategorySelectCell", bundle: nil)
        tableView.register(categoryNib, forCellReuseIdentifier: "CategorySelectCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func tapCancelButton(_ sender: Any) {
        categoryId.value = originarlCategoryId
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryId.value = categories[indexPath.row]

        // ジャンル選択画面へ遷移
        let vc: GenresViewController  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GenresViewController") as! GenresViewController
        vc.categoryId = categoryId
        vc.genreId = genreId

        // ナビゲーション
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell: CategorySelectCell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectCell") as! CategorySelectCell
            cell.categoryLabel.text = categories[indexPath.row].description
            return cell
    }
}
