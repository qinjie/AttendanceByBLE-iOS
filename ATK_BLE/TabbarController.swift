//
//  TabbarController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/7/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        var localdata = "timetable.txt"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            var filePath = dir.appendingPathComponent(localdata)
            
            // read from file
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? [Lesson]{
                
                GlobalData.timetable = dict
                
            }
            
            localdata = "lessonUUID.json"
            
            filePath = dir.appendingPathComponent(localdata)
            
            if let  dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? [Int:String]{
              //  print(JSON)
                GlobalData.lessonUUID = dict
            }
            
            
            localdata = "classmate.json"
            
            filePath = dir.appendingPathComponent(localdata)
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.path) as? [Classmate]{
                
                GlobalData.classmates = dict
                
            }
            
        }
        
        let today = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        GlobalData.currentDateStr = dateFormatter.string(from: today)
        
        GlobalData.today = GlobalData.timetable.filter({$0.ldate == GlobalData.currentDateStr})
        
        
        Constant.major = UserDefaults.standard.integer(forKey: "major")
        Constant.minor = UserDefaults.standard.integer(forKey: "minor")
        Constant.username = UserDefaults.standard.string(forKey: "username")!
        
        tabBar.isTranslucent = false
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor(red:0.90, green:0.91, blue:0.92, alpha:1.0).cgColor
        
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        
        let selectedColor   = UIColor.selected
        let unselectedColor = UIColor.unselected
        
        tabBar.unselectedItemTintColor = unselectedColor
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: unselectedColor], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: selectedColor], for: .selected)
        
        
        
        
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
