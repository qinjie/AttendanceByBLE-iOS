//
//  SettingController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/6/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class SettingController: UITableViewController {

    @IBAction func logout(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "username")
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.resetAppToFirstController()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
