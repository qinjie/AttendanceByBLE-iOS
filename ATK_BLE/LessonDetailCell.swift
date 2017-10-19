//
//  LessonDetailCell.swift
//  ATK_BLE
//
//  Created by KyawLin on 10/19/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class LessonDetailCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var detailedHistory: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(labelText:String,valueText:String,detailedButton:Bool){
        label.text = labelText
        value.text = valueText
        if detailedButton == true{
            detailedHistory.isHidden = false
        }else{
            detailedHistory.isHidden = true
        }
    }
    
}
