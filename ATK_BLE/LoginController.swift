//
//  LoginController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class LoginController: UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        /*if (UserDefaults.standard.value(forKey: "username") != nil){
         loadData()
         DispatchQueue.main.async {
         self.performSegue(withIdentifier: "sign in", sender: nil)
         }
         }*/
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginPressed(_ sender: UIButton) {
        
        if usernameTxt.text == "" || passwordTxt.text == ""{
            
            displayAlert(title: "Missing infomations", message: "Both username and password are required")
            
        }else{
            self.login()
        }
        
    }
    
    private func login(){
        let this_device = UIDevice.current.identifierForVendor?.uuidString
        let parameters:[String:Any] = [
            "username" : usernameTxt.text!,
            "password" : passwordTxt.text!,
            "device_hash" : this_device!
        ]
        
        //Set up SpinnerView
        let alertController = UIAlertController(title: "Loging in", message: "Please wait...\n\n", preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
        
        //Use the api to login
        Alamofire.request(Constant.URLstudentlogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response:DataResponse) in
            
            //Check the status code return from the api
            let code = response.response?.statusCode
            if code == 200{
                
                UserDefaults.standard.set(self.usernameTxt.text, forKey: "username")
                UserDefaults.standard.set(self.passwordTxt.text, forKey: "password")
                Constant.password = self.passwordTxt.text!
                Constant.username = self.usernameTxt.text!
                
                //retrieve JSON data
                if let JSON = response.result.value as? [String: AnyObject]{
                    
                    Constant.name = JSON["name"] as! String
                    Constant.token = JSON["token"] as! String
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    Constant.student_id = JSON[ "id"] as! Int
                    Constant.major = JSON["major"] as! Int
                    Constant.minor = JSON["minor"] as! Int
                    Constant.device_hash = JSON["device_hash"] as! String
                    UserDefaults.standard.set(Constant.device_hash, forKey: "device_hash")
                    //Check if the device is new
                    if Constant.device_hash != this_device{
                        Constant.change_device = true
                        
                    }else{
                        Constant.change_device = false
                    }
                    self.setupData()
                    UserDefaults.standard.set(Constant.major, forKey: "major")
                    UserDefaults.standard.set(Constant.minor, forKey: "minor")
                    UserDefaults.standard.set(Constant.name, forKey: "name")
                    UserDefaults.standard.set(Constant.student_id, forKey: "student_id")
                }
            }else{
                alertController.dismiss(animated: false, completion: nil)
                self.displayAlert(title: "LOGIN FAILED", message: "Username or password incorrect!")
            }
        })
        
    }
    
    private func setupData(){
        
        //Load all classmates
        let token = UserDefaults.standard.string(forKey: "token")
        //Load timetable, lecturer and lesson...
        let headersTimetable:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        
        Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersTimetable).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                
                GlobalData.timetable.removeAll()
                
                for json in JSON{
                    let newLesson = Lesson()
                    
                    if let lesson = json["lesson"] as? [String:Any]{
                        newLesson.lesson_id = lesson["id"] as? Int
                        newLesson.catalog = lesson["catalog_number"] as? String
                        newLesson.subject = lesson["subject_area"] as? String
                        newLesson.start_time = lesson["start_time"] as? String
                        newLesson.end_time = lesson["end_time"] as? String
                        newLesson.weekday = lesson["weekday"] as? String
                        newLesson.class_section = lesson["class_section"] as? String
                    }
                    
                    if let lecturer = json["lecturers"] as? [String:Any]{
                        
                        newLesson.lecturer = lecturer["name"] as? String
                        newLesson.lecAcad = lecturer["acad"] as? String
                        newLesson.lecEmail = lecturer["email"] as? String
                        newLesson.lecOffice = lecturer["office"] as? String
                        newLesson.lecPhone = lecturer["phone"] as? String
                    }
                    
                    if let lesson_date = json["lesson_date"] as? [String:Any]{
                        
                        newLesson.ldateid = lesson_date["id"] as? Int
                        newLesson.ldate = lesson_date["ldate"] as? String
                    }
                    
                    if let venue = json["venue"] as? [String:Any]{
                        
                        newLesson.major = venue["major"] as? Int32
                        newLesson.minor = venue["minor"] as? Int32
                        newLesson.venueName = venue["name"] as? String
                        newLesson.location = venue["location"] as? String
                    }
                    GlobalData.timetable.append(newLesson)
                }
                //Write timetable to the local directory
                NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.timetablePath)
                
                print("Done loading timetable")
                self.loadUUID()
                self.loadClassmate()
                self.loadHistory()
            }
            
        }
    }
    
    private func loadClassmate(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        
        let parameters: [String: Any] = [
            
            "student_id": Constant.student_id
        ]
        
        
        Alamofire.request(Constant.URLallClassmate, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            print("start load clssmates")
            if let JSON = response.result.value as? [[String: AnyObject]]{
                
                GlobalData.classmates.removeAll()
                for json in JSON{
                    let classmates = Classmate()
                    classmates.lesson_id = json["lesson_id"] as? Int
                    classmates.major = [Int]()
                    classmates.minor = [Int]()
                    classmates.student_id = [Int]()
                    
                    if classmates.lesson_id == 24{
                        
                    }
                    
                    if let list = json["students"] as? [[String:AnyObject]]{
                        for x in list{
                            let newId = x["id"] as! Int
                            if newId != Constant.student_id{
                                
                                classmates.student_id?.append(newId)
                                
                                if let y = x["beacon_user"] as? [String:AnyObject]{
                                    let newmajor = y["major"] as! Int
                                    classmates.major?.append(newmajor)
                                    let newminor = y["minor"] as! Int
                                    classmates.minor?.append(newminor)
                                }
                            }else{
                                
                                if let email = x["email"] as? String{
                                    UserDefaults.standard.set(email, forKey: "email")
                                }
                                else {
                                    UserDefaults.standard.removeObject(forKey: "email")
                                }
                                if let address =  x["address"] as? String{
                                    UserDefaults.standard.set(address, forKey: "address")
                                }
                                else {
                                    UserDefaults.standard.removeObject(forKey: "address")
                                }
                            }
                        }
                    }
                    
                    GlobalData.classmates.append(classmates)
                    
                }
                //Write classmates to local directory
                NSKeyedArchiver.archiveRootObject(GlobalData.classmates, toFile: filePath.classmatePath)
                
                print("Done loading classmates")
                self.performSegue(withIdentifier: "sign in", sender: nil)
                
            }else{
                print("load classmates parser error")
            }
        }
        
        
    }
    
    private func loadUUID(){
        //Load UUID
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        
        Alamofire.request(Constant.URLlessonUUID, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
            
            if let JSON = response.result.value as? [[String:AnyObject]]{
                
                var  dict = [Int:String]()
                for json in JSON{
                    let id = json["lesson_id"] as! Int
                    let uuid = json["uuid"] as! String
                    dict.updateValue(uuid, forKey: id)
                }
                GlobalData.lessonUUID = dict
                NSKeyedArchiver.archiveRootObject(GlobalData.lessonUUID, toFile: filePath.lessonuuidPath)
            }
            
        })
        //Load Attendance
        Alamofire.request(Constant.URLattendance, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
            if let JSON = response.result.value as? [[String:Any]]{
                GlobalData.attendance.removeAll()
                for json in JSON{
                    let history = Lesson()
                    history.ldateid = json["lesson_date_id"] as? Int
                    history.lecturer_id = json["lecturer_id"] as? Int
                    history.status = json["status"] as? Int
                    let time = Format.Format(date: Format.Format(string: (json["recorded_time"] as? String)!, format: "HH:mm:ss"), format: "HH:mm")
                    let lesson = (json["lesson_date"] as? [String:AnyObject])!
                    history.lesson_id = lesson["lesson_id"] as? Int
                    history.ldate = lesson["ldate"] as? String
                    //history.updated_by = lesson["updated_by"] as? Int
                    history.recorded_time = time
                    GlobalData.attendance.append(history)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.attendance, toFile: filePath.historyDTPath)
            }
        })
        print("Done setup data")
    }
    
    private func loadHistory(){
        
        let token = UserDefaults.standard.string(forKey: "token")!
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token
        ]
        Alamofire.request(Constant.URLhistory, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            GlobalData.history.removeAll()
            if let JSON = response.result.value as? [AnyObject]{
                for json in JSON{
                    let newHistory = History()
                    newHistory.name = json["lesson_name"] as? String
                    newHistory.absent = json["absented"] as? Int
                    newHistory.present = json["presented"] as? Int
                    newHistory.total = json["total"] as? Int
                    newHistory.late = json["late"] as? Int
                    GlobalData.history.append(newHistory)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.history, toFile: filePath.historyPath)
            }
            
        }
        
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
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayAlert(title:String,message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
