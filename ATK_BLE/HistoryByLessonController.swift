//
//  HistoryByDateController.swift
//  ATK_BLE
//
//  Created by KyawLin on 7/7/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class HistoryByLessonController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var lesson:Lesson!
    var history:[HistoryDT]!
    var count:Int!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = lesson.catalog
        if GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id}) != []{
            history = GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id})
            count = history.count
        }else{
            count = 0
            return
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LessonCell)!
        let mLesson = GlobalData.timetable.filter({$0.ldateid == history[indexPath.row].lesson_date_id}).first
        let mHistory = GlobalData.attendance.filter({$0.lesson_date_id == mLesson?.ldateid}).first
        cell.lesson = mLesson
        cell.venue.isHidden = true
        cell.iconView.isHidden = false
        if mHistory != nil {
            if mHistory?.status == 0 {
                cell.iconView.image = #imageLiteral(resourceName: "green")
                cell.arrivingtimeLabel.text = mHistory?.created_at
                cell.arrivingtimeLabel.isHidden = false
            }else if mHistory?.status == -1{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.isHidden = true
            }else{
                cell.iconView.image = #imageLiteral(resourceName: "red")
                cell.arrivingtimeLabel.text = mHistory?.created_at
                cell.arrivingtimeLabel.isHidden = false
            }
            
        }else{
            
            cell.iconView.image = #imageLiteral(resourceName: "questionmark")
            cell.arrivingtimeLabel.text = "00:00"
            cell.arrivingtimeLabel.isHidden = true
            
        }
        // Configure the cell...
        
        return cell
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
