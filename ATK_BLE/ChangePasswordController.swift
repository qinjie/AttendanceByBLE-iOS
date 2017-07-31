//
//  ChangePasswordController.swift
//  Attandance Taking System
//
//  Created by KyawLin on 6/27/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordController: UIViewController {
    
    @IBOutlet weak var oldTF: UITextField!
    @IBOutlet weak var newTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var trackPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        trackPasswordLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        
        if oldTF.text == "" || newTF.text == "" || confirmTF.text == ""{
            let alertController = UIAlertController(title: "Missing infomations", message: "Please enter all the fields", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alertController.dismiss(animated: false, completion: nil)
            })
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
        }else{
            self.changePassword()
        }
        
    }
    
    private func changePassword(){
        let token = UserDefaults.standard.string(forKey: "token")!
        if newTF.text! == confirmTF.text!{
            let parameters:[String:Any] = [
                "oldPassword" : oldTF.text!,
                "newPassword" : newTF.text!
            ]
            let headers:HTTPHeaders = [
                "Content-Type" : "application/json",
                "Authorization" : "Bearer " + token
            ]
            let alertController = UIAlertController(title: "Changing Password", message: "Please wait...\n\n", preferredStyle: .alert)
            let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
            spinnerIndicator.color = UIColor.black
            spinnerIndicator.startAnimating()
            alertController.view.addSubview(spinnerIndicator)
            self.present(alertController, animated: false, completion: nil)
            Alamofire.request(Constant.URLchangepass, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
                let code = (response.response?.statusCode)!
                print(code)
                alertController.dismiss(animated: false, completion: nil)
                switch code{
                case 200:
                    self.performSegue(withIdentifier: "change password", sender: nil)
                default:
                    let alert = UIAlertController(title: "Change Password", message: "Error", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        alert.dismiss(animated: false, completion: nil)
                    }))
                    self.present(alert, animated: false, completion: nil)
                }
            })
        }
    }
    
    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        if sender.text != newTF.text{
            trackPasswordLabel.textColor = UIColor.red
            trackPasswordLabel.text = "Not matched"
            trackPasswordLabel.isHidden = false
        }else{
            trackPasswordLabel.isHidden = true
        }
    }
    
    @IBAction func currentPassEnterPressed(_ sender: UITextField) {
        newTF.becomeFirstResponder()
    }
    
    @IBAction func newPassEnterPressed(_ sender: UITextField) {
        confirmTF.becomeFirstResponder()
    }
    
    @IBAction func confirmPassEnterPressed(_ sender: UITextField) {
        if oldTF.text == "" || newTF.text == "" || confirmTF.text == ""{
        }else{
            self.changePassword()
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
