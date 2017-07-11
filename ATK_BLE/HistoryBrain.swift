//
//  HistoryBrain.swift
//  ATK_BLE
//
//  Created by KyawLin on 7/10/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation

class HistoryBrain{
    
    static func arrangeHistory(){
        
        let date = Date()
        let today = Format.Format(date: date, format: "YYYY-MM-dd")
        for i in GlobalData.timetable.filter({$0.ldate == today}){
            if GlobalData.attendance.filter({$0.ldateid == i.ldateid}).first == nil{
                GlobalData.attendance.append(i)
            }
        }
        
        GlobalData.attendance.sort(by: {$0.ldate! > $1.ldate!})
        /*for i in GlobalData.attendance{
            print(i.ldate! + i.recorded_time!)
        }*/

    }
    
    static func getHistoryDate() -> [String]{
        
        var mDate = ""
        var date = [String]()
        
        for i in GlobalData.attendance{
            if mDate != i.ldate{
                mDate = i.ldate!
                date.append(i.ldate!)
            }
        }
        return date
    }
    
    static func getHistory(lessonid:Int) -> [Lesson]{
        
        if GlobalData.attendance.filter({$0.lesson_id == lessonid}) != []{
            return GlobalData.attendance.filter({$0.lesson_id == lessonid})
        }else{
            return []
        }
        
    }
    
    static func getHistory(ldate:String) -> [Lesson]{
        
        if GlobalData.attendance.filter({$0.ldate == ldate}) != []{
            return GlobalData.attendance.filter({$0.ldate == ldate})
        }else{
            return []
        }
        
    }
    
}
/*if GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id}) != []{
 history = GlobalData.attendance.filter({$0.lesson_id == lesson.lesson_id})
 count = history.count
 }else{
 count = 0
 return
 }
 print(count)*/
