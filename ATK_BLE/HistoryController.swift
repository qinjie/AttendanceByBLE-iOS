//
//  HistoryController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit

class HistoryController: UITableViewController {

    var wday = [String]()
    
    var wdayInt = [String]()
    
    let wdayDict: [String: Any] = [
        "2" : "Monday",
        "3" : "Tuesday",
        "4" : "Wednesday",
        "5" : "Thursday",
        "6" : "Friday",
        "7" : "Saturday"
    ]
    
    let wdayDict2: [String: Any] = [
        "Monday"    : "2",
        "Tuesday"   : "3",
        "Wednesday" : "4",
        "Thursday"  : "5",
        "Friday"    : "6",
        "Saturday"  : "7"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        let today = Format.Format(date: date, format: "EEEE")
        var i = Int(wdayDict2[today] as! String)!
        for _ in 0...5{
            if i == 1{
                i = 7
            }
            wday.append(wdayDict[String(i)] as! String)
            wdayInt.append(String(i))
            i -= 1
        }
        print(wday)
        print(wdayInt)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.timetable.filter({$0.weekday == wdayInt[section]}).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        let lessonInDay = GlobalData.timetable.filter({$0.weekday == wdayInt[indexPath.section]})
        
        let lesson = lessonInDay[indexPath.row]
        cell.lesson = lesson
        let history = GlobalData.attendance.filter({$0.lesson_date_id == lesson.ldateid}).first
        cell.venue.isHidden = true
        cell.iconView.isHidden = false
        if history != nil {
            if history?.status == 0 {
                cell.iconView.image = #imageLiteral(resourceName: "green")
                cell.arrivingtimeLabel.text = history?.created_at
                cell.arrivingtimeLabel.isHidden = false
            }
                
            else if history?.status == -1{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.isHidden = true
            }
                
            else{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.text = history?.created_at
                cell.arrivingtimeLabel.isHidden = false
            }
            
        }
        else{
            
            cell.iconView.image = #imageLiteral(resourceName: "questionmark")
            cell.arrivingtimeLabel.text = "00:00"
            cell.arrivingtimeLabel.isHidden = true
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell  else{ return }
        
        self.performSegue(withIdentifier: "lesson detail", sender: cell.lesson)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return wday[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "lesson detail"{
            if let destination = segue.destination as? LessonDetailController{
                if let lesson = sender as? Lesson{
                    destination.lesson = lesson
                }
            }
        }
        // Pass the selected object to the new view controller.
        
    }

}
