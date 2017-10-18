//
//  MoreController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class MoreController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var stepperValue:Int?
    var label = ["Name:","Email","Address","Notification"]
    var value = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = UIImage(named: "student")
        stepperValue = Int(UserDefaults.standard.string(forKey: "notification time")!)!
        
        tableView.delegate = self
        tableView.dataSource = self
        
        value.removeAll()
        value.append(UserDefaults.standard.string(forKey: "name")!)
        value.append(UserDefaults.standard.string(forKey: "email")!)
        value.append(UserDefaults.standard.string(forKey: "address")!)
        value.append("before \(stepperValue!) mins")
        let nib = UINib(nibName: "UserInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        
        NotificationCenter.default.removeObserver(UIApplication.shared.delegate!)
        UserDefaults.standard.removeObject(forKey: "student_id")
        UserDefaults.standard.set("-", forKey: "email")
        UserDefaults.standard.set("-", forKey: "address")
        self.performSegue(withIdentifier: "sign out", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserInfoCell
        
        if indexPath.row == 2{
            cell.commonInit(labelText: self.label[indexPath.row], valueText: self.value[indexPath.row], stepperBool: false)
        }else if indexPath.row == 3{
            cell.commonInit(labelText: self.label[indexPath.row], valueText: self.value[indexPath.row], stepperBool: true)
        }else{
            cell.commonInit(labelText: self.label[indexPath.row], valueText: self.value[indexPath.row], stepperBool: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
