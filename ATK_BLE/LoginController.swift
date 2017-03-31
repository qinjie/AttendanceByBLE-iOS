//
//  ViewController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/3/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

import Alamofire

class LoginController: UIViewController{
    

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginButtonTapped(_ sender: Any) {

        
        if ((usernameTextField.text == "") || (passTextField.text == "")) {
            
            displayMyAlertMessage(title: "Alert",mess: "All fields are required")
    
        }else{
            
        
            login()
        //   setupData()
           
        
        }
     
    }
    
    
    func loadAbc() {
        Alamofire.request("http://api.apixu.com/v1/current.json?key=3bf1a27308204a7a94e90405161911&q=Paris").responseJSON { response in
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Parse error")
                return
            }
//            let json = JSON(responseJSON)
//            let location = json["location"]
//            let name = location["name"].stringValue
//            let region = location["region"].stringValue
//            NSLog("\(name) +   \(region)"  )
            
        }
    }

    func login(){
       
        let parameters: [String: Any] =
            [
                "username": usernameTextField.text ,
                "password": passTextField.text,
                "device_hash":"f8:32:e4:5f:77:4fff"
                
                //"id" = "4"
                
        ]
        
        let alertController = UIAlertController(title: nil, message: "Please wait...\n\n", preferredStyle: UIAlertControllerStyle.alert)
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
        
        
        
        
        let urlString = Constant.URLstudentlogin
        
        print("url \(urlString)")
        //let urlString = Constants.baseURL + "/atk-ble/api/web/index.php/v1/timetable/today"
        //let urlString = Constants.baseURL + "/atk-ble/api/web/index.php/v1/lecturer/login"
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            let code = response.response?.statusCode
            if (code == 200){
 
                UserDefaults.standard.set(self.usernameTextField.text, forKey: "username")
                UserDefaults.standard.set(self.passTextField.text, forKey: "password")
                Constant.password = self.passTextField.text!
                Constant.username = self.usernameTextField.text!
                
                let thisdevice = UIDevice.current.identifierForVendor?.uuidString
                
                if let data = response.result.value{
                    print(data)
                }
                
                if let JSON = response.result.value as? [String: AnyObject]{
                    
                    
                    Constant.name = JSON["name"] as! String
                    Constant.token = JSON["token"] as! String
                    Constant.student_id = JSON["id"] as! Int
                    Constant.major = JSON["major"] as! Int
                    Constant.minor = JSON["minor"] as! Int
                    
                    Constant.device_hash = JSON["device_hash"] as! String
                    
                    if (Constant.device_hash != thisdevice){
                        
                        Constant.change_device = true
                        
                    }
                
                    // constant major minor status token
                    
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    UserDefaults.standard.set(Constant.major, forKey: "major")
                    UserDefaults.standard.set(Constant.minor, forKey: "minor")
                    UserDefaults.standard.set(Constant.username, forKey: "username")
                    
                    print("token \(Constant.token)")
                    
             
                        self.loadAllClassmate()
                    
                  
                    
                    
                    DispatchQueue.main.async {
                        self.loadattendance()
                        
                        self.loadUUID()
                    }
                }
            } else {
                
                alertController.dismiss(animated: true, completion: nil)
                self.displayMyAlertMessage(title: "LOGIN FAILED",mess: "Username or password is invalid!! ")
                
            }
            
            
        }
        
        NSLog("//======END TEST LOGIN1==========//")
       // setupData()
        
    }
    
    
    func setupData(){
        
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token
            // "Accept": "application/json"
        ]
    
        Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            print("load setup success")
            if let JSON = response.result.value as? [AnyObject]{
                
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
                        
                        
//                        newLesson.photo = (json["image_path"] as? String)!
//                        newLesson.remark = (json["remark"] as? String)!
//                        newLesson.nric = (json["nric"] as? String)!
//                        newLesson.dob = (json["dob"] as? String)!
                    

                    
                    GlobalData.timetable.append(newLesson)
                    
                    
                }
                
                
                print("*****TIMETABLE*****")
               
                let localdata = "timetable.txt"
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let filePath = dir.appendingPathComponent(localdata)
                    
                    NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.path)
                    
                }
            }
            

            
            DispatchQueue.main.async(execute: {
                //alertController.dismiss(animated: true, completion: nil)
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            })

           
      
            }
            // self.collectionView!.reloadData()
        }
    
    
    func loadAllClassmate(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!,
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] =
            [
                "student_id": Constant.student_id
        ]
        
        
        Alamofire.request(Constant.URLallClassmate, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            print("load classmate success")
            if let JSON = response.result.value as? [[String:AnyObject]]{
                for json in JSON{
                    let classmates = Classmate()
                    classmates.lesson_id = json["lesson_id"] as? Int!
                    classmates.major = [Int]()
                    classmates.student_id = [Int]()
                    classmates.minor = [Int]()
                    
                    if let list = json["students"] as? [[String:AnyObject]]{
                        for x in list{
                            let newId = x["id"] as? Int!
                            if (newId != Constant.student_id){
                                classmates.student_id?.append(newId!)
                                //print(x["beacon_user"])
                                if let y = x["beacon_user"] as? [String:AnyObject]{
                                   // print(y)
                                    let newmajor = y["major"] as? Int!
                                    classmates.major?.append(newmajor!)
                                    let newminor = y["minor"] as? Int!
                                    classmates.minor?.append(newminor!)
                                }
                            }
                        }
                    }
                    
                    GlobalData.classmates.append(classmates)
                    
                }
                
                let localdata = "classmate.json"
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let filePath = dir.appendingPathComponent(localdata)
                    
                    // write to file
                    NSKeyedArchiver.archiveRootObject(GlobalData.classmates, toFile: filePath.path)
                    
                    
                }
                
                print("load all classmate ")
                 self.setupData()
            }else{
                print("all classmate parser error")
            }
        }
    }
    
    func loadUUID(){

        let token = UserDefaults.standard.string(forKey: "token")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!
            // "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLlessonUUID, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let JSON = response.result.value as? [[String:AnyObject]]{
                
                let localdata = "lessonUUID.json" //this is the file. we will write to and read from it
                
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    
                    let filePath = dir.appendingPathComponent(localdata)
                    
                    // write to file
                    NSKeyedArchiver.archiveRootObject(JSON, toFile: filePath.path)
                    
                    
                }
                
                print("load uuid success")
            }
        }
    }
    

    func loadattendance(){
        print("load att ")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token
            // "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLattendance, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let JSON = response.result.value as? [[String:Any]]{
                for json in JSON{
                   let id = (json["lesson_date_id"] as? Int)!
                   GlobalData.attendance.append(id)
                }
            }
             print("load atk success")
        }
    }
    
}

