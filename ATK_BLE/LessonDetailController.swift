//
//  LessonDetailController.swift
//  Attandance Taking System
//
//  Created by KyawLin on 5/26/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit

class LessonDetailController: UIViewController {
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var subjectnameLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var teacherPhLabel: UILabel!
    @IBOutlet weak var teacherEmailLabel: UILabel!
    @IBOutlet weak var teacherOfficeLabel: UILabel!
    @IBOutlet weak var totalsessionLabel: UILabel!
    @IBOutlet weak var presentLabel: UILabel!
    @IBOutlet weak var lateLabel: UILabel!
    @IBOutlet weak var absentLabel: UILabel!
    
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
        //print(lesson.catalog)
        history = GlobalData.history.filter({$0.name == lesson.catalog}).first
        setupLabels()
        // Do any additional setup after loading the view.
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
        subjectLabel.text = lesson.subject! + " " + lesson.catalog!
        subjectnameLabel.text = lesson.catalog
        creditLabel.text = String(credit)
        groupLabel.text = lesson.class_section
        timeLabel.text = dict[Int(lesson.weekday!)!]! + "\n" + displayTime.display(time: lesson.start_time!) + " - " + displayTime.display(time: lesson.end_time!)
        venueLabel.text = lesson.location
        teacherLabel.text = lesson.lecturer
        teacherPhLabel.text = lesson.lecPhone
        teacherEmailLabel.text = lesson.lecEmail
        teacherOfficeLabel.text = lesson.lecOffice
        totalsessionLabel.text = String(finishedLessons) + " / " + String(describing: history.total!)
        presentLabel.text = String(describing: history.present!) + " (\(round(presentPer*100)/100)%)"
        lateLabel.text = String(describing: history.late!)
        absentLabel.text = String(describing: history.absent!)
    }
    
    @IBAction func detailedHistory(_ sender: UIButton) {
        
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
    
}
