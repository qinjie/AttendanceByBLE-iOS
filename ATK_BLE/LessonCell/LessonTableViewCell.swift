//
//  LessonTableViewCell.swift
//  ATK_BLE
//
//  Created by Anh Tuan on 6/9/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTimeStart : UILabel!
    @IBOutlet weak var lblTimeend : UILabel!
    @IBOutlet weak var lbllecturer : UILabel!
    @IBOutlet weak var lblsubject : UILabel!
    @IBOutlet weak var lblvenue : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(lesson : Lesson){
        lblsubject.text = (lesson.subject)! + " " + (lesson.catalog)!
        lbllecturer.text = "- " + lesson.lecturer!
        lblTimeStart.text = lesson.start_time
        lblTimeend.text = lesson.end_time
        lblvenue.text = "- " +
            lesson.venueName! + " " + (lesson.location)!
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
