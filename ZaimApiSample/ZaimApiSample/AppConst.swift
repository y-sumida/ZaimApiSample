//
//  AppConst.swift
//  ZaimApiSample
//
//  Created by 住田祐樹 on 2017/05/23.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import Foundation

let paymentCategories: [PaymentCategory] = [
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
        .other
    ]

let paymentGenres: [PaymentCategory:[PaymentGenre]] = [
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
