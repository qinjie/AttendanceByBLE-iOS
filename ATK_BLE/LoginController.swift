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
            displayMyAlertMessage(mess: "All fields are required")
    
        }
        
        login()
        //   setupData()
        UserDefaults.standard.set("canhnht", forKey: "username")
        UserDefaults.standard.set("123456", forKey: "password")
        
        
        //   clearData()
        //  self.setupData()
        
        /*   let username = usernameTextField.text
         let password = passTextField.text
         
         NSLog("========START TEST LOGIN 1=======")
         let parameters: [String: Any] = ["username": username,
         "password": password,
         "device_hash":"f8:32:e4:5f:77:4fff"
         ]
         
         let urlString = Constants.baseURL + "/atk-ble/api/web/index.php/v1/student/login"
         Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
         
         guard let responseJSON = response.result.value as? [String: AnyObject] else {
         print("Parse error")
         return
         }
         
         let json = JSON(responseJSON)
         let name = json["name"].stringValue
         
         if (name == "Bad Request"){
         print("IT HAS ERROR WHEN LOGIN ")
         print(response.result.error)
         self.displayMyAlertMessage(mess: "username or pass or device is invalid")
         
         }else{
         if let data = response.result.value{
         print("IT HAS DATA WHEN LOGIN ")
         print(data)
         // login successfull
         UserDefaults.standard.set(true, forKey: "isUserLogin")
         UserDefaults.standard.synchronize()
         self.dismiss(animated: true, completion: nil)
         }
         }
         NSLog("//======END TEST LOGIN==========//")
         }*/
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
        NSLog("zzz l========START TEST LOGIN =======")
        let parameters: [String: Any] =
            [
                "username":"canhnht",
                "password":"123456",
                "device_hash":"f8:32:e4:5f:77:4fff"
                
                //"id" = "4"
                
        ]
        let urlString = Constant.URLstudentlogin
        
        print("url \(urlString)")
        //let urlString = Constants.baseURL + "/atk-ble/api/web/index.php/v1/timetable/today"
        //let urlString = Constants.baseURL + "/atk-ble/api/web/index.php/v1/lecturer/login"
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    print(data)
                }
               
                if let JSON = response.result.value as? [String: AnyObject]{
                    
                    Constant.username = JSON["name"] as! String
                    Constant.token = JSON["token"] as! String
                    Constant.user_id = JSON["id"] as! Int
                 // constant majo minor status token
                    
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    
                    print("token \(Constant.token)")
                    
                    self.setupData()

                }
                break
                
            case .failure(_):
                print("IT HAS ERROR WHEN LOGIN ")
                print(response.result.error)
                break
            }
            
            
        }
        
        NSLog("//======END TEST LOGIN1==========//")
       // setupData()
        
    }
    
    
    func setupData(){
        
        //  let token = "QAMoEorbGpaE6j1__4MyCQRedeHDskzJ"
        let token = UserDefaults.standard.string(forKey: "token")
        // token = "Bearer " + token!
        print("Token2: \(token)")
        //let parameters: [String: Any] = ["Authorization": token]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!
            // "Accept": "application/json"
        ]
    
        Alamofire.request(Constant.URLtimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let JSON = response.result.value as? [AnyObject]{
                
                for json in JSON {
                    
                    let newLesson = Lesson()
                    
                    if let lesson = json["lesson"] as? [String: Any]{
                        
                        newLesson.lesson_id = (lesson["id"] as? Int)!
                        newLesson.name = (lesson["catalog_number"] as? String)!
                        newLesson.start_time = (lesson["start_time"] as? String)!
                        newLesson.end_time = (lesson["end_time"] as? String)!
                        newLesson.weekday = (lesson["weekday"] as? String)!
                    }
                    
                    if let lesson_date = json["lesson_date"] as? [String: Any]{
                        
                        newLesson.ldateid = (lesson_date["id"] as? Int)!
                        newLesson.ldate = (lesson_date["ldate"] as? String)!
                        
                    }
                    
                    if let venue = json["venue"] as? [String: Any]{
                        
                        newLesson.major = (venue["major"] as? Int32)!
                        newLesson.minor = (venue["minor"] as? Int32)!
                        newLesson.venueName = (venue["name"] as? String)!
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
            
            
            
            print("HELLO")
//            guard let responseJSON = response.result.value as? [[String: AnyObject]]
//                else {
//                    print("Parse error2")
//                    return
//            }
            
            DispatchQueue.main.async(execute: {
                //alertController.dismiss(animated: true, completion: nil)
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            })
//            let jsons = JSON(responseJSON)
//            // print("JSON  \(jsons)")
//            
//            let delegate = UIApplication.shared.delegate as? AppDelegate
//            
//            if let context = delegate?.managedObjectContext {
//                
//                for json in jsons.array! {
//                    
//                    let newLesson = NSEntityDescription.insertNewObject(forEntityName: "Lesson", into: context) as! Lesson
//                    
//                    newLesson.lessonName = String(describing: json["lesson"]["subject_area"])
//                    newLesson.lecturer = String(describing: json["lecturers"]["name"])
//                    newLesson.sTime = String(describing: json["lesson"]["start_time"])
//                    newLesson.eTime = String(describing: json["lesson"]["end_time"])
//                    
//                    let newVenue = NSEntityDescription.insertNewObject(forEntityName: "Venue", into: context) as! Venue
//                    newVenue.id = String(describing: json["venue"]["id"])
//                    newVenue.location = String(describing: json["location"])
//                    newVenue.name = String(describing: json["venue"]["name"])
//                    newVenue.uuid = String(describing: json["venue"]["uuid"])
//                    newVenue.major = String(describing: json["venue"]["major"])
//                    newVenue.minor = String(describing: json["venue"]["minor"])
//                    
//                    newLesson.venue = newVenue
//                    
//                }
                /*
                 let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
                 request.returnsObjectsAsFaults = false
                 
                 do {
                 let lssons = try! context.fetch(request) as! [Lesson]
                 
                 print("zzz le setup to view \(lssons.count)")
                 
                 //  self.loadData()
                 }catch{
                 fatalError("Failed to fetch employees: \(error)")
                 }
                 */
           
      
            }
            // self.collectionView!.reloadData()
        }
    
        // Setup data of venue
        
   //     url = Constant.baseURL + "/atk-ble/api/web/index.php/v1/venue"
        //        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
        //
        //            guard let responseJSON = response.result.value as? [[String: AnyObject]]
        //                else {
        //                    print("Parse error2")
        //                    return
        //            }
        //            let jsons = JSON(responseJSON)
        //            print("JSON  \(jsons)")
        //
        //            let delegate = UIApplication.shared.delegate as? AppDelegate
        //
        //            if let context = delegate?.managedObjectContext {
        //
        //                for json in jsons.array! {
        //
        //                    let newVenue = NSEntityDescription.insertNewObject(forEntityName: "Venue", into: context) as! Venue
        //
        //                    newVenue.id = String(describing: json["id"])
        //                    newVenue.location = String(describing: json["location"])
        //                    newVenue.name = String(describing: json["name"])
        //                    newVenue.uuid = String(describing: json["uuid"])
        //                    newVenue.major = String(describing: json["major"])
        //                    newVenue.minor = String(describing: json["minor"])
        //                }
        //                /*
        //                 let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")
        //                 request.returnsObjectsAsFaults = false
        //
        //                 do {
        //                 let lssons = try! context.fetch(request) as! [Lesson]
        //
        //                 print("zzz le setup to view \(lssons.count)")
        //
        //                 //  self.loadData()
        //                 }catch{
        //                 fatalError("Failed to fetch employees: \(error)")
        //                 }
        //                 */
        //                do {
        //                    try(context.save())
        //                } catch let err {
        //                    print(err)
        //                }
        //            }
        //            // self.collectionView!.reloadData()
        //        }
        
        
   // }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    /*
     let usernameStored = UserDefaults.standard.string(forKey: "username")
     let passwordStored = UserDefaults.standard.string(forKey: "password")
     if ((username == usernameStored) && (password == passwordStored)){
     // login successfull
     
     UserDefaults.standard.set(true, forKey: "isUserLogin")
     UserDefaults.standard.synchronize()
     dismiss(animated: true, completion: nil)
     }*/
    
    
}
extension UIViewController {
        func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
        }
    
        func dismissKeyboard() {
            view.endEditing(true)
        }
    
    func displayMyAlertMessage(mess : String){
        
        var myAlert = UIAlertController(title: "Alert", message: mess, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default, handler: nil)
        
        // okAction.setValue(image, forKey: "image")
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        imageView.image = UIImage(named: "warn")
        myAlert.view.addSubview(imageView)
        
        myAlert.addAction(okAction)
        
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
}
