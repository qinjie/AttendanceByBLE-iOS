//
//  HistoryCell.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/31/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var present: UILabel!
    @IBOutlet weak var absent: UILabel!
    @IBOutlet weak var total: UILabel!
    var lesson : History!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        name.text = lesson.name
        total.text = lesson.total.description
        absent.text = lesson.absent.description
        present.text = lesson.present.description
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
