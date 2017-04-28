//
//  LessonCell.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/6/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class LessonCell: UITableViewCell {
    
    //    let profileImageView: UIImageView = {
    //        let imageView = UIImageView()
    //        imageView.contentMode = .scaleAspectFill
    //        imageView.layer.cornerRadius = 34
    //        imageView.layer.masksToBounds = true
    //        return imageView
    //    }()
    
    var lesson: Lesson?{
        didSet {
            
            subjectLabel.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            lecturer.text = lesson?.lecturer
            start_time.text = lesson?.start_time
            end_time.text = lesson?.end_time
            venue.text = lesson?.venueName
        }
    }
    
    let lessonPhoto: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.image = UIImage(named: "yoo2")
        
        imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        return imageView
        
    }()
    
    let lecturer: UILabel = {
        let label = UILabel()
        label.text = "ABC"
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red:0.00, green:0.36, blue:0.16, alpha:0.5)
        // view.backgroundColor = UIColor(red:0, green:0.92, blue:0.41, alpha:0.5)
        return view
    }()
    
    let subjectLabel: UILabel = {
        let label = UILabel()
        label.text = "Xu Helios"
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    let start_time: UILabel = {
        let label = UILabel()
        label.text = "starttime"
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let end_time: UILabel = {
        let label = UILabel()
        label.text = "endtime"
      
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let venue: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let lastseen: UILabel = {
        let label = UILabel()
        label.text = "......"
        label.textColor = UIColor(red:0.10, green:0.31, blue:0.17, alpha:1.0)
        //  label.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.93, alpha:0.5)
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    let statusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupContainerView()
        
//        contentView.addSubview(venue)
//        contentView.addSubview(subjectLabel)
//        contentView.addSubview(start_time)
//        contentView.addSubview(end_time)
       // contentView.addSubview(dividerLineView)
 
        
//        //   statusImage.image = UIImage(named: "dol")
//        
//        contentView.addConstraintsWithFormat("H:|-20-[v0][v1]-12-|", views: subjectLabel, start_time)
//        contentView.addConstraintsWithFormat("H:|-20-[v0][v1]-12-|", views: venue, end_time)
//        
//        contentView.addConstraintsWithFormat("V:|-15-[v0]-15-[v1]-15-|", views: subjectLabel, venue)
//        contentView.addConstraintsWithFormat("V:|-15-[v0]-15-[v1]-15-|", views: start_time, end_time)
////        
////        addConstraint(NSLayoutConstraint(item: lessonPhoto, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
//        
//        contentView.addConstraintsWithFormat("H:|-10-[v0]-10-|", views: dividerLineView)
//        contentView.addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
    }
    
    fileprivate func setupContainerView() {
        let containerView = UIView()
        contentView.addSubview(containerView)
        
        contentView.addConstraintsWithFormat("H:|[v0]|", views: containerView)
        contentView.addConstraintsWithFormat("V:[v0(100)]", views: containerView)
        contentView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        containerView.addSubview(venue)
        containerView.addSubview(subjectLabel)
        containerView.addSubview(start_time)
        containerView.addSubview(end_time)
        containerView.addSubview(lecturer)
        
        containerView.addConstraintsWithFormat("H:|-20-[v0][v1(70)]-12-|", views: subjectLabel, start_time)
        
        containerView.addConstraintsWithFormat("H:|-20-[v0][v1(70)]-12-|", views: venue, end_time)
        containerView.addConstraintsWithFormat("H:|-20-[v0]", views: lecturer)
        containerView.addConstraintsWithFormat("V:|-15-[v0]-30-[v1]-15-|", views: start_time, end_time)
        
        containerView.addConstraintsWithFormat("V:|-10-[v0]-12-[v1]-12-[v2]-7-|", views: subjectLabel,lecturer, venue)
    }
    
}



extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...) {
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
    
}
