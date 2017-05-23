
//
//  ZaimCode.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/20.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

enum MoneyMode: String {
    case income = "income"
    case payment = "payment"
}

enum PaymentCategory : Int {
    case food = 101
    case dailyGoods = 102
    case transport = 103
    case phoneNet = 104
    case utilities = 105
    case home = 106
    case socializing = 107
    case hobbies = 108
    case education = 109
    case medical = 110
    case fashion = 111
    case other = 199

    var description: String {
        switch self {
        case .food: return "食費"
        case .dailyGoods: return "日用雑貨"
        case .transport: return "交通"
        case .phoneNet: return "通信"
        case .utilities: return "水道・光熱"
        case .home: return "住まい"
        case .socializing: return "交際"
        case .hobbies: return "エンタメ"
        case .education: return "教育"
        case .medical: return "医療"
        case .fashion: return "美容・衣服"
        case .other: return "その他"
        }
    }
}

enum PaymentGenre : Int {
    case groceries = 10101
    case cafe = 10102
    case breakfast = 10103
    case lunch = 10104
    case dinner = 10105
    case foodOther = 10199
    case consumable = 10201
    case childRelated = 10202
    case petRelated = 10203
    case tobacco = 10204
    case dailyGoodsOther = 10299
    case train = 10301
    case taxi = 10302
    case bus = 10303
    case airfares = 10304
    case transportOther = 10399
    case cellPhone = 10401
    case fixedLinePhones = 10402
    case internetRelated = 10403
    case tvLicense = 10404
    case delivery = 10405
    case postcardStamps = 10406
    case phoneNetOther = 10499
    case water = 10501
    case electricity = 10502
    case gas = 10503
    case utilitiesOther = 10599
    case rent = 10601
    case mortgage = 10602
    case furniture = 10603
    case homeElectronics = 10604
    case reform = 10605
    case homeInsurance = 10606
    case homeOther = 10699
    case party = 10701
    case gifts = 10702
    case ceremonialEvents = 10703
    case socializingOther = 10799
    case leisure = 10801
    case events = 10802
    case cinema = 10803
    case music = 10804
    case cartoon = 10805
    case books = 10806
    case games = 10807
    case hobbiesOther = 10899
    case adultTuitionFees = 10901
    case newspapers = 10902
    case referenceBook = 10903
    case examinationFee = 10904
    case tuition = 10905
    case studentInsurance = 10906
    case cramSchool = 10907
    case educationOther = 10999
    case hospital = 11001
    case prescription = 11002
    case lifeInsurance = 11003
    case medicalInsurance = 11004
    case medicalOther = 11099
    case clothes = 11101
    case accessories = 11102
    case underwear = 11103
    case gymHealth = 11104
    case beautySalon = 11105
    case cosmetics = 11106
    case estheticClinic = 11107
    case laundry = 11108
    case fashionOther = 11199
    case other = 19999

    var description: String {
        switch self {
        case .groceries: return "食料品"
        case .cafe: return "カフェ"
        case .breakfast: return "朝ごはん"
        case .lunch: return "昼ごはん"
        case .dinner: return "晩ごはん"
        case .foodOther: return "その他"
        case .consumable: return "消耗品"
        case .childRelated: return "子ども関連"
        case .petRelated: return "ペット関連"
        case .tobacco: return "タバコ"
        case .dailyGoodsOther: return "その他"
        case .train: return "電車"
        case .taxi: return "タクシー"
        case .bus: return "バス"
        case .airfares: return "飛行機"
        case .transportOther: return "その他"
        case .cellPhone: return "携帯電話"
        case .fixedLinePhones: return "固定電話"
        case .internetRelated: return "インターネット関連"
        case .tvLicense: return "放送サービス"
        case .delivery: return "宅配便"
        case .postcardStamps: return "切手はがき"
        case .phoneNetOther: return "その他"
        case .water: return "水道"
        case .electricity: return "電気"
        case .gas: return "ガス"
        case .utilitiesOther: return "その他"
        case .rent: return "家賃"
        case .mortgage: return "住宅ローン"
        case .furniture: return "家具"
        case .homeElectronics: return "家電"
        case .reform: return "リフォーム"
        case .homeInsurance: return "住宅保険"
        case .homeOther: return "その他"
        case .party: return "飲み会"
        case .gifts: return "プレゼント"
        case .ceremonialEvents: return "冠婚葬祭"
        case .socializingOther: return "その他"
        case .leisure: return "レジャー"
        case .events: return "イベント"
        case .cinema: return "映画"
        case .music: return "音楽"
        case .cartoon: return "漫画"
        case .books: return "書籍"
        case .games: return "ゲーム"
        case .hobbiesOther: return "その他"
        case .adultTuitionFees: return "習い事"
        case .newspapers: return "新聞"
        case .referenceBook: return "参考書"
        case .examinationFee: return "受験料"
        case .tuition: return "学費"
        case .studentInsurance: return "学資保険"
        case .cramSchool: return "塾"
        case .educationOther: return "その他"
        case .hospital: return "病院"
        case .prescription: return "薬"
        case .lifeInsurance: return "生命保険"
        case .medicalInsurance: return "医療保険"
        case .medicalOther: return "その他"
        case .clothes: return "衣服"
        case .accessories: return "アクセサリー"
        case .underwear: return "下着"
        case .gymHealth: return "ジム・健康"
        case .beautySalon: return "美容院"
        case .cosmetics: return "コスメ"
        case .estheticClinic: return "エステ"
        case .laundry: return "クリーニング"
        case .fashionOther: return "その他"
        case .other: return "その他"
        }
    }

    var parentCategory: PaymentCategory {
       return PaymentCategory(rawValue: self.rawValue / 100)!
    }
}
