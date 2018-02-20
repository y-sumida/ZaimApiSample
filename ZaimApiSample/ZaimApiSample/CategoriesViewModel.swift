//
//  CategoriesViewModel.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2018/02/17.
//  Copyright © 2018年 Yuki Sumida. All rights reserved.
//

import RealmSwift

class CategoriesViewModel {
    private let realm: Realm
    var categories: [Category] = []

    init() {
        realm = try! Realm()
        categories = realm.objects(Category.self).filter("active == 1").map { $0 }
    }
}

