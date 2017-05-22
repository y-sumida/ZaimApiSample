//
//  GenreSelectCell.swift
//  ZaimApiSample
//
//  Created by Yuki Sumida on 2017/05/22.
//  Copyright © 2017年 Yuki Sumida. All rights reserved.
//

import UIKit

class GenreSelectCell: UITableViewCell {
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        checkIcon.isHidden = !selected
    }
    
}
