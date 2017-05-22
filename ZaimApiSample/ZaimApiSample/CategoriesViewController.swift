//
//  CategoriesViewController.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/21.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit

class CategoriesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

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
        self.dismiss(animated: true, completion: nil)
    }
}

extension CategoriesViewController: UITableViewDelegate {
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
