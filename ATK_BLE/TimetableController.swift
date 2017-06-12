//
//  TimetableController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//
import Alamofire
import UIKit

class TimetableController: BaseTableViewController {

    fileprivate let cellId = "cell"
    
    var JSON : [[String:Any]]!
    
   
    
    let wday = ["Monday", "Tuesday", "Wednesday", "Thursday" , "Friday", "Saturday"]
    
    let wdayInt = ["2", "3", "4", "5", "6", "7"]
    let cellID = "LessonTableViewCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("check 1")
        //collectionView?.register(LessonCell.self, forCellWithReuseIdentifier: cellId)
      //  self.tableView.register(LessonCell.self, forCellReuseIdentifier: "cell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib.init(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.separatorColor = UIColor.seperatorApp
        
        navigationItem.title = "Weekly Timetable"
        NotificationCenter.default.addObserver(self,selector: #selector(rload), name: NSNotification.Name(rawValue: "atksuccesfully"), object: nil)
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.mainApp
        refreshControl?.addTarget(self, action: #selector(TimetableController.setupData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    
    }
    
    
    @IBAction func sync(_ sender: Any) {
        setupData()
    }
    
    func rload(){
        displayMyAlertMessage(title: "Successfull Attendance", mess: "You had taken attendance for \(GlobalData.currentLesson.catalog!)")
        self.tableView.reloadData()                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
    }
    
    // MARK: - Table view data source
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        
        let indexPath = getIndexPathForSelectedCell()
        
                guard let cell = tableView.cellForRow(at: indexPath!) as? LessonCell else { return }
                let x = cell.lesson
                let detailPage = segue.destination as! LessonDetailView
                detailPage.lesson = x!
       
        
        
    }
    
    func getIndexPathForSelectedCell() -> IndexPath? {
        
        var indexPath:IndexPath?
        
            indexPath = tableView.indexPathForSelectedRow
    
        return indexPath
    }
    
    func setupData(){
        
        var today = Date()
        
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: today)
        
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + Constant.token
                // "Accept": "application/json"
            ]
            
            Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                self.refreshControl?.endRefreshing()
                print("load setup success")
                if let JSON = response.result.value as? [AnyObject]{
                    GlobalData.timetable.removeAll()
                    for json in JSON {
                        
                        let newLesson = Lesson()
                        
                        if let lesson = json["lesson"] as? [String: Any]{
                            
                            newLesson.lesson_id = (lesson["id"] as? Int)!
                            newLesson.catalog = (lesson["catalog_number"] as? String)!
                            newLesson.subject = (lesson["subject_area"] as? String)!
                            newLesson.start_time = (lesson["start_time"] as? String)!
                            newLesson.end_time = (lesson["end_time"] as? String)!
                            newLesson.weekday = (lesson["weekday"] as? String)!
                        }
                        
                        if let lecturer = json["lecturers"] as? [String: Any]{
                            
                            newLesson.lecturer = (lecturer["name"] as? String)!
                            newLesson.acad = (lecturer["acad"] as? String)!
                            newLesson.email = (lecturer["email"] as? String)!
                            //   print(newLesson.lecturer)
                        }
                        
                        
                        if let lesson_date = json["lesson_date"] as? [String: Any]{
                            
                            newLesson.ldateid = (lesson_date["id"] as? Int)!
                            newLesson.ldate = (lesson_date["ldate"] as? String)!
                            
                        }
                        
                        if let venue = json["venue"] as? [String: Any]{
                            
                            newLesson.major = (venue["major"] as? Int32)!
                            newLesson.minor = (venue["minor"] as? Int32)!
                            newLesson.venueName = (venue["name"] as? String)!
                            newLesson.location = (venue["location"] as? String)!
                            
                        }
                 
                        GlobalData.timetable.append(newLesson)
                        
                        
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatedata"), object: nil)
                    
                    print("*****TIMETABLE*****")
                    
                    let localdata = "timetable.txt"
                    
                    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        
                        let filePath = dir.appendingPathComponent(localdata)
                        
                        let str = ""
                        
                        do {
                            try str.write(to: filePath, atomically: true, encoding: String.Encoding.utf8)
                        } catch {
                        
                        }
                        
                        NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.path)
                        
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                
                }
 
                
            }
            // self.collectionView!.reloadData()
        
    }

}
extension TimetableController {
    override func numberOfSections(in tableView: UITableView) -> Int{
        
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  GlobalData.timetable.filter({$0.weekday == wdayInt[section]}).count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 120.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LessonTableViewCell
        
        // Configure the cell...
        let lessonInDay = GlobalData.timetable.filter({$0.weekday == wdayInt[indexPath.section]})
        
        let lesson = lessonInDay[indexPath.row]
        cell.setData(lesson: lesson)
        
        if (GlobalData.attendance.contains((lesson.ldateid)!)){
            cell.backgroundColor = UIColor(red:0.84, green:1.00, blue:0.95, alpha:1.0)
        }else{
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        
        return wday[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell else { return }
        
        self.performSegue(withIdentifier: "lessonDetailSegue2", sender: nil)
    }
}
