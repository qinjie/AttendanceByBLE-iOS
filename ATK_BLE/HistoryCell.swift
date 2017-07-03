//
//  HistoryCell.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/23/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    let subjectLabel:UILabel = {
       let label = UILabel()
        label.text = "Subject"
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let classLabel:UILabel = {
        let label = UILabel()
        label.text = "Class"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gray
        return label
    }()
    
    let start_timeLabel:UILabel = {
        let label = UILabel()
        label.text = "start_time"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let end_timeLabel:UILabel = {
        let label = UILabel()
        label.text = "end_time"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let arrivingtimeLabel:UILabel = {
        let label = UILabel()
        label.text = "arriving time"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let iconLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        label.text = "?"
        label.font = UIFont.systemFont(ofSize: 15)
        label.layer.cornerRadius = 12
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
