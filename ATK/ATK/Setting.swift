//
//  SettingControllerViewController.swift
//  ATKdemo
//
//  Created by xuhelios on 12/12/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit
import CoreData

class Setting: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var info: UITableView!
    
    @IBOutlet weak var userinfo: UITextField!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.info.dataSource = self
        self.info.delegate = self
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 5.0
        self.profileImage.layer.borderColor = UIColor.white.cgColor
   
        userinfo.text = Constants.name
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func LogoutBtnTapped(_ sender: Any) {
  
        clearData()
    }

    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        
        if let context = delegate?.managedObjectContext {
            
            do {
                
                let entityNames = ["Lesson", "Venue", "Subject"]
                
                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                    
                }
                
                try(context.save())
                
                            } catch let err {
                print(err)
            }
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    let fields: [String] = ["Username", "Id", "Email", "Sheep", "Goat"]

    
    // #pragma mark - Table view data source
    func tableView(_ tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView!, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    fileprivate let cellId = "infoCell"
    
    func tableView(_ tableView: UITableView!, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId , for: indexPath) as! InfoCell
   
      //  cell.icon.image = UIImage(named: "email")
        cell.infoDetail.text = self.fields[indexPath.row]
        return cell
    }
    
}
class InfoCell: UITableViewCell {
    
//    @IBOutlet weak var icon: UIImageView!
//    @IBOutlet weak var infoDetail: UILabel!
    var icon = UIImageView()
    var infoDetail = UILabel()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(icon)
        self.contentView.addSubview(infoDetail)
      
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        eventName = UILabel(frame: CGRectMake(20, 10, self.bounds.size.width - 40, 25))
//        eventCity = UILabel(frame: CGRectMake(0, 0, 0, 0))
//        eventTime = UILabel(frame: CGRectMake(0, 0, 0, 0))
        
    }
}




