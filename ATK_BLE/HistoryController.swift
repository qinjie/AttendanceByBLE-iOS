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
    var wdayDate = [String]()
    var wdayInt = [String]()
    var historyDate = [String]()
    
    let wdayDict: [String: Any] = [
        "2" : "Monday",
        "3" : "Tuesday",
        "4" : "Wednesday",
        "5" : "Thursday",
        "6" : "Friday"
    ]
    
    let wdayDict2: [String: Any] = [
        "Monday"    : "2",
        "Tuesday"   : "3",
        "Wednesday" : "4",
        "Thursday"  : "5",
        "Friday"    : "6"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyDate = HistoryBrain.getHistoryDate()
        /*var date = Date()
        let today = Format.Format(date: date, format: "EEEE")
        var i = 0
        var mDate = Format.Format(date: date, format: "dd MMM")
        if  let j = wdayDict2[today] as? String{
            i = Int(j)!
        }
        else{
            if today == "Saturday"{
                date = date.addingTimeInterval(-60*60*24)
            }
            else{
                date = date.addingTimeInterval(-60*60*24*2)
            }
            i = 6
        }
        mDate = Format.Format(date: date, format: "dd MMM")
        for _ in 0...4{
            if i == 1{
                i = 6
            }
            wday.append(wdayDict[String(i)] as! String)
            wdayInt.append(String(i))
            wdayDate.append(mDate)
            
            if Format.Format(date: date, format: "EEEE") == "Monday"{
                date = date.addingTimeInterval(-60*60*24*3)
                i = 6
            }
            else{
                date = date.addingTimeInterval(-60*60*24)
                i -= 1
            }
            mDate = Format.Format(date: date, format: "dd MMM")
        }*/
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.attendance.filter({$0.ldate == historyDate[section]}).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        let historyInDay = GlobalData.attendance.filter({$0.ldate == historyDate[indexPath.section]})
        let history = historyInDay[indexPath.row]
        let lesson = GlobalData.timetable.filter({$0.lesson_id == history.lesson_id}).first
        
        cell.lesson = lesson
        cell.venue.isHidden = true
        cell.iconView.isHidden = false
        if history.status != nil {
            if history.status == 0 {
                cell.iconView.image = #imageLiteral(resourceName: "green")
                cell.arrivingtimeLabel.text = history.recorded_time
                cell.arrivingtimeLabel.isHidden = false
            }
                
            else if history.status == -1{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.isHidden = true
            }
                
            else{
                cell.iconView.image = #imageLiteral(resourceName: "yellow")
                cell.arrivingtimeLabel.text = history.recorded_time
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
        return Format.Format(date: Format.Format(string: historyDate[section], format: "yyyy-MM-dd"), format: "EEEE(dd MMM)")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return historyDate.count
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
