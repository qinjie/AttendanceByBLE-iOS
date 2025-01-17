//
//  TimetableController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class TimetableController: UITableViewController {

    fileprivate let cellId = "cell"
    
    var JSON : [[String:Any]]!
    
    var names = ["Vegetables": ["Tomato", "Potato", "Lettuce"], "Fruits": ["Apple", "Banana"]]
    
    let wday = ["Monday", "Tuesday", "Wednesday", "Thursday" , "Friday", "Saturday", "Sunday"]
    
    let wdayInt = ["2", "3", "4", "5", "6", "7", "8"]
    
    struct Objects {
        
        var sectionName : String!
        var sectionObjects : [String]!
    }
    
    var objectArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("check 1")
        //collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)
      //  self.tableView.register(LessonCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        navigationItem.title = "Weekly Timetable"
        
//        let SyncBtn = UIBarButtonItem(title: "Sync", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LoginController.setupData))
//        SyncBtn.image = UIImage(named: "sync30")
//        self.navigationItem.rightBarButtonItem = SyncBtn
    
    }

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int{
      
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return  GlobalData.timetable.filter({$0.weekday == wdayInt[section]}).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
    
    // Configure the cell...
        let lessonInDay = GlobalData.timetable.filter({$0.weekday == wdayInt[indexPath.section]})

        let lesson = lessonInDay[indexPath.row]
        cell.lesson = lesson
            //   print("cell \(cell.subjectLabel.text)")
//        cell.idLabel.text = lesson.lesson_id?.description
//        cell.start_time.text = lesson.start_time
//        cell.end_time.text = lesson.end_time
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    
        return wday[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell else { return }
        
        print(cell.lesson?.name)
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
