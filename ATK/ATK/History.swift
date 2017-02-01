//
//  History.swift
//  ATKdemo
//
//  Created by xuhelios on 11/26/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//
//
//  Today2ViewController.swift
//  ATKdemo
//
//  Created by xuhelios on 12/9/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class HistoryController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    fileprivate let cellId = "cellId"
    
    var subjects : [Subject]?

    func loadData(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subject")
            request.returnsObjectsAsFaults = false
            
            do {
                subjects = try! context.fetch(request) as! [Subject]
            }catch{
                fatalError("Failed to fetch \(error)")
            }
            
            subjects = subjects?.sorted(by: {$0.name!.compare($1.name! as String) == .orderedAscending})
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.collectionView!.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupData()
        self.loadData()
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 100)
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // self.navigationController!.popViewController(animated: true)!
        navigationItem.title = "Today"
        
        collectionView?.backgroundColor = UIColor.white//(red:1.00, green:0.80, blue:0.74, alpha:1.0)
        
        //collectionView?.backgroundColor = UIColor(patternImage: UIImage(named: "hisbg")!)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.register(SubjectCell.self, forCellWithReuseIdentifier: cellId)
        
        
        DispatchQueue.main.async {
            self.collectionView!.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = subjects?.count {
            
            
            return count
        }
        
        return 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SubjectCell
        if let subject = subjects?[indexPath.item] {
            cell.subject = subject
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //     let layout = UICollectionViewFlowLayout()
        //   let controller = UIViewController()
        // controller.friend = messages?[indexPath.item].friend
//        let controller = self.storyboard?.instantiateViewController(withIdentifier: "atkController") as! atkController
//        self.navigationController?.pushViewController(controller, animated: true)
//        if self.navigationController != nil {
//            self.navigationController?.pushViewController(controller, animated: true)
//        } else {
//            NSLog("Nil cmnr")
//        }
        
        //navigationController?.pushViewController(controller, animated: true)
        //var navController = self.navigationController!
    }
    
    
}

class SubjectCell: BaseCell {
    
    //    let profileImageView: UIImageView = {
    //        let imageView = UIImageView()
    //        imageView.contentMode = .scaleAspectFill
    //        imageView.layer.cornerRadius = 34
    //        imageView.layer.masksToBounds = true
    //        return imageView
    //    }()
    
    var subject: Subject?{
        didSet {
            nameLabel.text = subject?.name
            total.text = subject?.total
            present.text = subject?.present
            absent.text = subject?.absent
           // print("total  \(subject?.total)")
            //print("present  \(subject?.present)")
            //  timeLabel.text?.appending(etime)
            
        }
    }
    
    let numLabel: UILabel = {
        //        let view = UIView()
        //        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        //        return view
        
        let label = UILabel()
        label.text = "1"
        label.font = UIFont.systemFont(ofSize: 15)
        label.backgroundColor = UIColor.black
        return label
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "mathematics"
        label.textColor = UIColor.orange
        label.textAlignment = .center
            //UIColor(red:0.90, green:0.29, blue:0.10, alpha:1.0)
        label.font = UIFont(name:"Futura",size:16)
        return label
    }()
    
    
    
    let dividerLineView: UIView = {
        let view = UIView()
        // view.backgroundColor = UIColor(red:0.51, green:0.83, blue:0.93, alpha:0.5)
        view.backgroundColor = UIColor(red:0, green:0.92, blue:0.41, alpha:0.5)
        return view
    }()
    
    let total: UILabel = {
        let label = UILabel()
        label.text = "T30"
        label.font = UIFont(name:"Futura",size:12)
        //  boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        
        return label
    }()
    let totalImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "tt")
        imageView.contentMode = .scaleAspectFill
       // imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
      //  imageView.backgroundColor = UIColor.blue
        return imageView
    }()

    let present: UILabel = {
        let label = UILabel()
        label.text = "P12"
        label.textAlignment = .center
        label.font = UIFont(name:"Futura",size:12)
        return label
    }()
    let presentImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "p2")
        imageView.contentMode = .scaleAspectFill
       // imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
       // imageView.backgroundColor = UIColor.blue
        return imageView
    }()
    
    let absent: UILabel = {
        let label = UILabel()
        label.text = "A12"
        label.textAlignment = .center
        
        label.font = UIFont(name:"Futura",size:12)
        return label
    }()
    let absentImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "c")
        imageView.contentMode = .scaleAspectFill
    //    imageView.layer.cornerRadius = 34
        imageView.layer.masksToBounds = true
        //imageView.backgroundColor = UIColor.blue
        return imageView
    }()
    
    override func setupViews() {
        
     //   addSubview(nameLabel)
        addSubview(dividerLineView)
//        
        addConstraintsWithFormat("H:|-10-[v0]-10-|", views: dividerLineView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerLineView)
        
        let containerView = UIView()
       // containerView.backgroundColor = UIColor(red:0.90, green:0.29, blue:0.10, alpha:1.0)
        
        addSubview(containerView)
        addConstraintsWithFormat("V:|[v0]-10-|", views:containerView)
        addConstraintsWithFormat("H:|-10-[v0]-10-|", views:containerView)
      //  addConstraintsWithFormat("V:|[v0(35)]-5-[v1(35)]", views: nameLabel,containerView)
       // addConstraintsWithFormat("H:|[v0]|", views: nameLabel)
     
       // addConstraint(NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        containerView.layer.cornerRadius = 10;
        containerView.layer.masksToBounds = true;
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(total)
        containerView.addSubview(totalImg)
        containerView.addSubview(present)
        containerView.addSubview(presentImg)
        containerView.addSubview(absent)
        containerView.addSubview(absentImg)
        containerView.addConstraintsWithFormat("H:|[v0]|", views: nameLabel)
        containerView.addConstraintsWithFormat("V:|-5-[v0(30)]", views: nameLabel)
        containerView.addConstraintsWithFormat("H:|-35-[v0]-15-[v1]-35-[v2]-15-[v3]-35-[v4]-15-[v5]", views: totalImg, total, presentImg, present, absentImg, absent)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: total)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: totalImg)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: present)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: presentImg)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: absent)
        containerView.addConstraintsWithFormat("V:[v0]-10-|", views: absentImg)

        
    }
    override var isSelected: Bool {
        didSet {
          //  if(isSelected){
            contentView.backgroundColor = isSelected ? UIColor.orange : UIColor.white
            //}
            
            // layer.borderWidth = isSelected ? 4 : 0
        }
    }
    
}

extension UIView {
    
    func addConstraintsWithFormat(_ format: String, views: UIView...){
        
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.blue
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.orange : UIColor.white
            // layer.borderWidth = isSelected ? 4 : 0
        }
    }
}

