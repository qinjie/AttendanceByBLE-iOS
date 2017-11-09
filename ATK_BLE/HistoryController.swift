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
        tableView.tableFooterView = UIView(frame: .zero)
        historyDate = HistoryBrain.getHistoryDate()
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true {
        alamofire.loadHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "done loading history"), object: nil)
        }
        else {
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    private func turnOnData() {
        let url = URL(string: "App-Prefs:root=WIFI") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    @objc func refreshTable(){
        
        self.tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.attendance.filter({$0.ldate == historyDate[section]}).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        let historyInDay = GlobalData.attendance.filter({$0.ldate == historyDate[indexPath.section]})
        let lesson = historyInDay[indexPath.row]
        
        cell.lesson = lesson
        cell.venue.isHidden = true
        cell.iconView.isHidden = false
        if lesson.status != nil {
            if lesson.status == 0 {
                cell.iconView.image = #imageLiteral(resourceName: "green")
                cell.arrivingtimeLabel.text = lesson.recorded_time
                cell.arrivingtimeLabel.isHidden = false
            }
                
            else if lesson.status == -1{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.isHidden = true
            }
                
            else{
                cell.iconView.image = #imageLiteral(resourceName: "yellow")
                cell.arrivingtimeLabel.text = lesson.recorded_time
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
