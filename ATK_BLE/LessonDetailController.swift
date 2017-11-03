//
//  LessonDetailController.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/26/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit

class LessonDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let label = ["Name:","Credit:","Group:","Timeslot:","Venue:","Teacher:","Attendance Statistics","Total Sessions:","Present:","Late:","Absent:"]
    
    private var value = [String]()
    
    private var dict = [
        2 : "Monday",
        3 : "Tuesday",
        4 : "Wednesday",
        5 : "Thursday",
        6 : "Friday"
    ]
    
    var lesson:Lesson!
    var history:History!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        history = GlobalData.history.filter({$0.name == lesson.catalog}).first
        setupLabels()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: .zero)
        
        GlobalData.currentHistoryLesson = lesson
        
        let nib = UINib(nibName: "LessonDetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private var credit:Int{
        var credit = 0
        let weekSession = GlobalData.timetable.filter({$0.catalog == lesson.catalog})
        for session in weekSession{
            credit += calTimeDiff(start_time: session.start_time!, end_time: session.end_time!)
        }
        return credit
    }
    
    private func setupLabels(){
        
        let finishedLessons = history.present! + history.late! + history.absent!
        var presentPer = 0.0
        if finishedLessons != 0{
            presentPer = Double(history.present!)/Double((finishedLessons))*100
        }else{
            presentPer = 0
        }
        
        if let mLesson = GlobalData.timetable.filter({$0.lesson_id == lesson.lesson_id}).first{
            lesson.lecturer = mLesson.lecturer
            lesson.lecPhone = mLesson.lecPhone
            lesson.lecEmail = mLesson.lecEmail
            lesson.lecOffice = mLesson.lecOffice
        }
        
        value.append(lesson.catalog!)
        value.append(String(credit))
        value.append(lesson.class_section!)
        value.append(dict[Int(lesson.weekday!)!]! + "\n" + displayTime.display(time: lesson.start_time!) + " - " + displayTime.display(time: lesson.end_time!))
        value.append(lesson.location!)
        value.append(lesson.lecturer! + "\n" + lesson.lecPhone! + "\n" + lesson.lecEmail! + "\n" + lesson.lecOffice!)
        value.append(" ")
        value.append(String(finishedLessons) + " / " + String(describing: history.total!))
        value.append(String(describing: history.present!) + " (\(round(presentPer*100)/100)%)")
        value.append(String(describing: history.late!))
        value.append(String(describing: history.absent!))
        
    }
    
    @objc private func detailedHistory(){
        self.performSegue(withIdentifier: "lesson detail by date", sender: self.lesson)
    }

    
    private func calTimeDiff(start_time:String, end_time:String) -> Int{
        
        let startSplit = start_time.components(separatedBy: ":")
        let sHour = Int(startSplit[0])!
        let endSplit = end_time.components(separatedBy: ":")
        let eHour = Int(endSplit[0])!
        return eHour - sHour
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! HistoryByLessonController
        destinationVC.lesson = sender as! Lesson
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3{
            return 60
        }else if indexPath.row == 5{
            return 100
        }else{
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return lesson.subject! + " " + lesson.catalog!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonDetailCell
        if indexPath.row == 3{
            cell.value.numberOfLines = 2
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], detailedButton: false)
        }else if indexPath.row == 5{
            cell.value.numberOfLines = 4
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], detailedButton: false)
        }else if indexPath.row == 6 {
            cell.label.font = UIFont.boldSystemFont(ofSize: 19)
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], detailedButton: true)
            cell.detailedHistory.addTarget(self, action: #selector(detailedHistory), for: .touchUpInside)
        }else{
            cell.value.numberOfLines = 1
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], detailedButton: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.systemFont(ofSize: 25)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
