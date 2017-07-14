//
//  TimetableController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire

class TimetableController: UITableViewController {
    
    let today = Date()
    let dateFormatter = DateFormatter()
    var JSON : [[String:Any]]!
    
    let wday = ["Monday", "Tuesday", "Wednesday", "Thursday" , "Friday", "Saturday"]
    
    let wdayInt = ["2", "3", "4", "5", "6", "7"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dateFormatter.dateFormat = "MMM dd (E)"
        let title = dateFormatter.string(from: today)
        navigationItem.title = "Timetable \(title)"
        
        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell  else{ return }
        
        self.performSegue(withIdentifier: "lesson detail", sender: cell.lesson)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.timetable.filter({$0.weekday == wdayInt[section]}).count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        let lessonInDay = GlobalData.timetable.filter({$0.weekday == wdayInt[indexPath.section]})
        
        let lesson = lessonInDay[indexPath.row]
        cell.lesson = lesson
        if GlobalData.currentLesson.ldateid == lesson.ldateid{
            cell.backgroundColor = UIColor(red: 0.84, green: 1.00, blue: 0.95, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return wday[section]
    }
    
    @IBAction func RefreshButtonPressed(_ sender: UIBarButtonItem) {
        alamofire.loadTimetable()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "done loading timetable"), object: nil)
    }
    
    @objc func refreshTable(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateTime"), object: nil)
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let destination = segue.destination as! LessonDetailController
        // Pass the selected object to the new view controller.
        if let lesson = sender as? Lesson{
            destination.lesson = lesson
        }
    }
    
}
