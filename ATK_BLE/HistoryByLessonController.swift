//
//  HistoryByLessonController.swift
//  ATK_BLE
//
//  Created by Kyaw Lin on 9/11/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class HistoryByLessonController: UITableViewController {
    
    var lesson:Lesson!
    var history:[Lesson]!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        self.title = lesson.catalog
        if GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id}) != []{
            history = GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id})
            count = history.count
        }else{
            count = 0
            return
        }
        
        refreshControl?.addTarget(self, action: #selector(refreshHistory), for: .valueChanged)
        print(count)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshHistory(){
        alamofire.loadHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name(rawValue: "done loading history"), object: nil)
    }
    
    @objc private func refreshTable(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "done loading history"), object: nil)
        refreshControl?.endRefreshing()
        NotificationCenter.default.post(name: Notification.Name(rawValue:"update attendance"), object: nil)
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LessonCell)!
        let mHistory = history[indexPath.row]
        let lesson = GlobalData.timetable.filter({$0.lesson_id == mHistory.lesson_id}).first
        lesson?.status = GlobalData.attendance.filter({$0.lesson_id == lesson?.lesson_id}).first?.status
        cell.lesson = lesson
        cell.venue.isHidden = true
        cell.iconView.isHidden = false
        cell.isUserInteractionEnabled = false
        let ldate = Format.Format(date: Format.Format(string: mHistory.ldate!, format: "yyyy-MM-dd"), format: "dd/MM/yy")
        if mHistory.status == 0 {
            cell.iconView.image =  #imageLiteral(resourceName: "green")
            cell.arrivingtimeLabel.text = ldate
        }else if mHistory.status == -1{
            cell.iconView.image =  #imageLiteral(resourceName: "red")
            cell.arrivingtimeLabel.text = ldate
        }else{
            cell.iconView.image =  #imageLiteral(resourceName: "yellow")
            cell.arrivingtimeLabel.text = ldate + " " + String(describing: (lesson?.status!)!) + " mins"
        }
        // Configure the cell...
        cell.arrivingtimeLabel.isHidden = false
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
