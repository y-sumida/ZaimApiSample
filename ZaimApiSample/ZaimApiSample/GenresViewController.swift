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

    fileprivate var selectedGenreId: PaymentGenre!
    var categoryId: Variable<PaymentCategory>!
    var genreId: Variable<PaymentGenre>!

    fileprivate let genres: [PaymentCategory:[PaymentGenre]] = [
        .food: [.groceries, .cafe, .breakfast, .lunch, .dinner, .foodOther],
        .dailyGoods: [.consumable, .childRelated, .petRelated, .tobacco, .dailyGoodsOther],
        .transport: [.train, .taxi, .bus, .airfares, .transportOther],
        .phoneNet: [.cellPhone, .fixedLinePhones, .internetRelated, .tvLicense, .delivery, .postcardStamps, .phoneNetOther],
        .utilities: [.water, .electricity, .gas, .utilitiesOther],
        .home: [.rent, .mortgage, .furniture, .homeElectronics, .reform, .homeInsurance, .homeOther],
        .socializing: [.party, .gifts, .ceremonialEvents, .socializingOther],
        .hobbies: [.leisure, .events, .cinema, .music, .cartoon, .books, .games, .hobbiesOther],
        .education: [.adultTuitionFees, .newspapers, .referenceBook, .examinationFee, .tuition, .studentInsurance,.cramSchool,.educationOther],
        .medical: [.hospital, .prescription, .lifeInsurance, .medicalInsurance, .medicalOther],
        .fashion: [.clothes, .accessories, .underwear, .gymHealth, .beautySalon, .cosmetics, .estheticClinic, .laundry, .fashionOther],
        .other: [.other]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // ナビゲーションバー設定
        if let navi = navigationController {
            navi.setNavigationBarHidden(false, animated: true)
            navigationItem.title = "ジャンル"
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

    @IBAction func tapDoneButton(_ sender: Any) {
        genreId.value = selectedGenreId
        self.dismiss(animated: true, completion: nil)
    }
}

extension GenresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGenreId = (genres[categoryId.value]?[indexPath.row])!
    }
}

extension GenresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres[categoryId.value]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO ジャンル用のセルを作る
        let cell: CategorySelectCell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectCell") as! CategorySelectCell
        cell.categoryLabel.text = genres[categoryId.value]?[indexPath.row].description
        return cell
    }
}
