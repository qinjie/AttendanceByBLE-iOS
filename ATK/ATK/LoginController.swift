//
//  ViewController.swift
//  ATK
//
//  Created by xuhelios on 12/21/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class LoginController: UIViewController , ESTBeaconManagerDelegate{
    let beaconManager = ESTBeaconManager()
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")! as UUID,
        identifier: "ranged region")
    let placesByBeacons = [
        "58949:29933": [
            "Heavenly Sandwiches": 3, // read as: it's 50 meters from
            // "Heavenly Sandwiches" to the beacon with
            // major 6574 and minor 54631
            "Green & Green Salads": 5,
            "Mini Panini": 2
        ],
        "24890:6699": [
            "Heavenly Sandwiches": 2,
            "Green & Green Salads": 10,
            "Mini Panini": 2
        ],
        "52689:51570": [
            "Heavenly Sandwiches": 3,
            "Green & Green Salads": 5,
            "Mini Panini": 1
        ]
    ]
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.beaconManager.delegate = self
        // 4. We need to request this authorization for every beacon manager
        self.beaconManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func placesNearBeacon(beacon: CLBeacon) -> [String]? {
        let beaconKey = "\(beacon.major):\(beacon.minor)"
        if let places = self.placesByBeacons[beaconKey] {
            let sortedPlaces = Array(places).sorted { $0.1 < $1.1 }.map { $0.0 }
            return sortedPlaces
        }
        return nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginBtnTapped(_ sender: Any) {
 
        if ((usernameTextField.text != "") && (passTextField.text != "")) {
            //            displayMyAlertMessage(mess: "All fields are required")
            //        }
            Constants.username = self.usernameTextField.text!
            Constants.password = self.passTextField.text!
       // if (txtUsername.text == "" || txtPassword.text == ""){
            //txtErrorMessage.text = "Please insert all feild"
            //txtErrorMessage.text = ""
            //Wating dialog
            let alertController = UIAlertController(title: nil, message: "Please wait...\n\n", preferredStyle: UIAlertControllerStyle.alert)
            let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
            spinnerIndicator.color = UIColor.black
            spinnerIndicator.startAnimating()
            alertController.view.addSubview(spinnerIndicator)
            self.present(alertController, animated: false, completion: nil)
            let url = URL(string: Constants.baseURL + "/atk-ble/api/web/index.php/v1/student/login")
            let headers: HTTPHeaders = ["":""]
            let parameters: Parameters = [

                "username":Constants.username,
                "password":Constants.password,
                "device_hash":"f8:32:e4:5f:77:4fff"
                
//                "username":"tungpm",
//                "password":"123456",
//                "device_hash":"1"
                
            ]
            
            Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                let statusCode = response.response?.statusCode
                if (statusCode == 200){
                    if let JSON = response.result.value as? [String: Any] {
                        
                        Constants.token = JSON["token"] as! String
                        Constants.name = JSON["name"] as! String
                        Constants.id = JSON["id"] as! Int
                        Constants.username = self.usernameTextField.text!
                        
                        DispatchQueue.main.async(execute: {
                            //alertController.dismiss(animated: true, completion: nil)
                            OperationQueue.main.addOperation {
                                self.performSegue(withIdentifier: "segueLogin", sender: nil)
                            }
                        })
                        self.setupData()
                    }
                }
                else{
                    if (statusCode == 400){
                        DispatchQueue.main.async(execute: {
                            alertController.dismiss(animated: true, completion: nil)
                        //    self.txtErrorMessage.text = "Incorrect data!"
                        })
                    }
                    else{
                        DispatchQueue.main.async(execute: {
                            alertController.dismiss(animated: true, completion: nil)
                          //  self.txtErrorMessage.text = "Server error!"
                        })
                    }
                }
            }
            
        }
        else{
            
            displayMyAlertMessage(mess: "All fields are required")
            
        }

        
//        UserDefaults.standard.set("canhnht", forKey: "username")
//        UserDefaults.standard.set("123456", forKey: "password")
        

    }
    
    
    func loadAbc() {
        Alamofire.request("http://api.apixu.com/v1/current.json?key=3bf1a27308204a7a94e90405161911&q=Paris").responseJSON { response in
            guard let responseJSON = response.result.value as? [String: AnyObject] else {
                print("Parse error")
                return
            }
            let json = JSON(responseJSON)
            let location = json["location"]
            let name = location["name"].stringValue
            let region = location["region"].stringValue
            NSLog("\(name) +   \(region)"  )
            
        }
    }
    
    //    func displayMyAlertMessage(mess : String){
    //
    //        var myAlert = UIAlertController(title: "Alert", message: mess, preferredStyle: UIAlertControllerStyle.alert)
    //
    //        let okAction = UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default, handler: nil)
    //
    //        myAlert.addAction(okAction)
    //
    //        self.present(myAlert, animated: true, completion: nil)
    //
    //    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    var present = Set<String>()
    
    func checkAtd(){
        
        present = []
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constants.token
            // "Accept": "application/json"
        ]
        let url = Constants.baseURL + "/atk-ble/api/web/index.php/v1/attendance"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            guard let responseJSON = response.result.value as? [[String: AnyObject]]
                else {
                    print("Parse error3")
                    return
            }
            let jsons = JSON(responseJSON)
            
            for json in jsons.array! {
                
                self.present.insert(String(describing: json["lesson_date_id"]))
                
            }
            
        }

    }
    
    func setupData(){
        
        checkAtd()

        let token = Constants.token
     
        print("Token3: \(token)")
 
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token
            // "Accept": "application/json"
        ]
        
        var url = Constants.baseURL + "/atk-ble/api/web/index.php/v1/timetable?expand=lesson,lesson_date,lecturers,venue"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            guard let responseJSON = response.result.value as? [[String: AnyObject]]
                else {
                    print("Parse error3")
                    return
            }
            let jsons = JSON(responseJSON)
            // print("JSON  \(jsons)")
            
            let delegate = UIApplication.shared.delegate as? AppDelegate
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let context = delegate?.managedObjectContext {
                
                for json in jsons.array! {
                    
                    let newLesson = NSEntityDescription.insertNewObject(forEntityName: "Lesson", into: context) as! Lesson
                    
                    newLesson.lessonName = String(describing: json["lesson"]["subject_area"])
                    newLesson.lecturer = String(describing: json["lecturers"]["name"])
                    newLesson.sTime = String(describing: json["lesson"]["start_time"])
                    newLesson.eTime = String(describing: json["lesson"]["end_time"])
                    newLesson.lDateId = String(describing: json["lesson_date"]["id"])
                    newLesson.id = String(describing: json["lesson_id"])
                    
                    //newLesson.id = Int32(json["lesson_id"].int!)
                   // let id = json["lesson_id"].int
                
                  //  imageListItem.getInt("user_photo_id")
              
                    
                    //var dateAsString = String(describing: json["lesson_date"]["ldate"])
                    
//                    var newDate = dateFormatter.date(from: dateAsString)
//                    newLesson.lDate = newDate as NSDate?
                    newLesson.lDate = String(describing: json["lesson_date"]["ldate"])
                    let newVenue = NSEntityDescription.insertNewObject(forEntityName: "Venue", into: context) as! Venue
                    newVenue.id = String(describing: json["venue"]["id"])
                    newVenue.location = String(describing: json["location"])
                    newVenue.name = String(describing: json["venue"]["name"])
                    newVenue.uuid = String(describing: json["venue"]["uuid"])
                    newVenue.major = String(describing: json["venue"]["major"])
                    newVenue.minor = String(describing: json["venue"]["minor"])
                    
                    if (self.present.contains(newLesson.lDateId!)){
                        
                        newLesson.st = 0
                    
                    }else {
                        newLesson.st = -2
                        
                    }
                    
                    newLesson.venue = newVenue
                    
                }

                do {
                    try(context.save())
                } catch let err {
                    print(err)
                }
            }
            // self.collectionView!.reloadData()
        }
        
        // Setup data of History Controller
        
       // url = Constants.baseURL + "/atk-ble/api/web/index.php/v1/venue"
        url = Constants.baseURL + "/atk-ble/api/web/index.php/v1/student/history"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
        
                    guard let responseJSON = response.result.value as? [[String: AnyObject]]
                        else {
                            print("Parse error2")
                            return
                    }
                    let jsons = JSON(responseJSON)
                 //   print("JSON  \(jsons)")
        
                    let delegate = UIApplication.shared.delegate as? AppDelegate
        
                    if let context = delegate?.managedObjectContext {
        
                        for json in jsons.array! {
        
                            let newSubject = NSEntityDescription.insertNewObject(forEntityName: "Subject", into: context) as! Subject
        
                            newSubject.total = String(describing: json["total"])
                            newSubject.absent = String(describing: json["absented"])
                            newSubject.name = String(describing: json["lesson_name"])
                            newSubject.present = String(describing: json["presented"])
                        
                        }
             
                        do {
                            try(context.save())
                        } catch let err {
                            print(err)
                        }
                    }
                    // self.collectionView!.reloadData()
                }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.beaconManager.startRangingBeacons(in: self.beaconRegion)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.beaconManager.stopRangingBeacons(in: self.beaconRegion)
    }
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
    override func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

