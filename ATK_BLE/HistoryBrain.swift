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
        var history = [Lesson]()
        var tempHistory = [Lesson]()
        var ldate = ""
        for i in GlobalData.attendance{
            let lesson = GlobalData.timetable.first(where: {$0.lesson_id == i.lesson_id})
            i.start_time = lesson?.start_time
            if i.ldate != ldate{
                tempHistory.sort(by: {$0.start_time!<$1.start_time!})
                for i in tempHistory{
                    history.append(i)
                }
                tempHistory.removeAll()
                ldate = i.ldate!
            }
            tempHistory.append(i)
        }
        GlobalData.attendance = history
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
