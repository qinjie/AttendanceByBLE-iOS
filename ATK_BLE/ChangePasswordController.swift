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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        let token = Constant.token
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
                let code = response.result
                alertController.dismiss(animated: true, completion: nil)
                switch code{
                case .success(_): /*notification.createAlert(VC: self, title: "Change Password", message: "Successful", actionMsg: "OK")*/break
                case .failure(let error): print(error.localizedDescription)
                }
            })
        }
        /*let parameters:[String:Any] = [
            "username" : usernameTxt.text!,
            "password" : passwordTxt.text!,
            "device_hash" : this_device!
        ]
         let headersTimetable:HTTPHeaders = [
         "Authorization" : "Bearer " + token!
         ]*/
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
