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

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        usernameTxt.delegate = self
        passwordTxt.delegate = self
        usernameTxt.returnKeyType = .done
        passwordTxt.returnKeyType = .done
        usernameTxt.addTarget(self, action: #selector(usernameDonePressed), for: .editingDidEnd)
        
        removeKeyBoardNotification()
        registerKeyBoardNotification()
        
        if let username = UserDefaults.standard.string(forKey: "username"){
            usernameTxt.text = username
            passwordTxt.becomeFirstResponder()
        }else{
            usernameTxt.placeholder = "Name"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginPressed(_ sender: UIButton) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if usernameTxt.text == "" || passwordTxt.text == ""{
            displayAlert(title: "Missing infomations", message: "Both username and password are required")
            
        }
        else {
            if appdelegate.isInternetAvailable() == true {
               self.login()
            }
            else {
                 displayAlert(title: "LOGIN FAILED", message: "Your phone has no internet connection!")
            }
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
                    if let device_hash = JSON["device_hash"] as? String{
                        Constant.device_hash = device_hash
                        UserDefaults.standard.set(Constant.device_hash, forKey: "device_hash")
                    }else{
                        Constant.device_hash = ""
                        UserDefaults.standard.set(Constant.device_hash, forKey: "device_hash")
                    }
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done loading timetable"), object: nil)
        NotificationCenter.default.addObserver(self , selector: #selector(doneLoadingTimetable), name: Notification.Name(rawValue:"done loading timetable"), object: nil)
        alamofire.loadTimetable()
    }
    
    @objc func doneLoadingTimetable(){
        self.loadUUID()
        self.loadClassmate()
        self.loadHistory()
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
            log.info("start load classmates")
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
                                }else {
                                    UserDefaults.standard.removeObject(forKey: "email")
                                }
                                if let address =  x["address"] as? String{
                                    UserDefaults.standard.set(address, forKey: "address")
                                }else {
                                    UserDefaults.standard.removeObject(forKey: "address")
                                }
                                if let card = x["card"] as? String{
                                    UserDefaults.standard.set(card, forKey: "card")
                                }else{
                                    UserDefaults.standard.removeObject(forKey: "card")
                                }
                            }
                        }
                    }
                    
                    GlobalData.classmates.append(classmates)
                    
                }
                //Write classmates to local directory
                NSKeyedArchiver.archiveRootObject(GlobalData.classmates, toFile: filePath.classmatePath)
                
                log.info("Done loading classmates")
                self.removeKeyBoardNotification()
                NotificationCenter.default.removeObserver(self)
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
        alamofire.loadHistory()
        
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
    
    @objc func usernameDonePressed() {
        passwordTxt.becomeFirstResponder()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 30
            } else {
                self.keyboardHeightLayoutConstraint?.constant = ((endFrame?.size.height)! + 2) ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    private func removeKeyBoardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func registerKeyBoardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayAlert(title:String,message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
