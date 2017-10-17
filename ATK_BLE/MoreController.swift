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
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var notificationTime: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var tableView: UITableView!
    var stepperValue:Int?
    var label = ["Name:","Email","Address"]
    var value = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = UIImage(named: "student")
        username.text = UserDefaults.standard.string(forKey: "name")
        email.text = UserDefaults.standard.string(forKey: "email")
        address.text = UserDefaults.standard.string(forKey: "address")
        stepperValue = Int(UserDefaults.standard.string(forKey: "notification time")!)!
        notificationTime.text = "before \(stepperValue!) mins"
        stepper.value = Double(stepperValue!)
        
        value.removeAll()
        value.append(UserDefaults.standard.string(forKey: "name")!)
        value.append(UserDefaults.standard.string(forKey: "email")!)
        value.append(UserDefaults.standard.string(forKey: "address")!)
        
        tableView.delegate = self
        tableView.dataSource = self
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
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        stepperValue = Int(sender.value)
        notificationTime.text = "before \(stepperValue!) mins"
        UserDefaults.standard.set(stepperValue, forKey: "notification time")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stepper changed"), object: nil)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("UserInfoCell", owner: self, options: nil)?.first as? UserInfoCell
        cell?.label.text = label[indexPath.row]
        cell?.value.text = value[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != 2 {
            return 100
        }else{
            return 300
        }
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
