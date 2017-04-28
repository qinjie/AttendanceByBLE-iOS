//
//  SettingController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/6/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class SettingController: UITableViewController {

    @IBOutlet weak var name: UILabel!
    
    @IBAction func logout(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "username")
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.resetAppToFirstController()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        Constant.name = UserDefaults.standard.string(forKey: "name")!
        name.text = Constant.name
        navigationItem.title = "Setting"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func oldPass(){
        
        let alert = UIAlertController(title: "Change Password", message: "Please enter old password: ", preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: { action in
            let rm = alert.textFields![0] as UITextField
            
            if (Constant.password != rm.text){
                self.displayMyAlertMessage(title: "Failed", mess: "Your old password is wrong!!")
            }else{
                self.newPass()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
    
        }))
        
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Old Password"
            textField.textAlignment = .center
        })
        
        self.present(alert, animated: true, completion: nil)
    }

    func newPass(){
        
        let alert = UIAlertController(title: "New Password", message: "Please enter new password: ", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: { action in
            let rm = alert.textFields![0] as UITextField
            
            if (Constant.password != rm.text){
                self.displayMyAlertMessage(title: "Failed", mess: "Your old password is wrong!!")
            }else{
                self.newPass()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
            
        }))
        
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Old Password"
            textField.textAlignment = .center
        })
        
        self.present(alert, animated: true, completion: nil)
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
