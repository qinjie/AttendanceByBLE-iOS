//
//  ChangePassController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/24/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Alamofire
import UIKit

class ChangePassController: BaseViewController {

    @IBOutlet weak var currentPass: UITextField!
    
    @IBOutlet weak var newPass: UITextField!
    
    @IBOutlet weak var retypePass: UITextField!
    
    @IBOutlet weak var mess: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        mess.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func change(_ sender: Any) {
        
        if (currentPass.text != Constant.password){
            
            mess.text = "Your current password is typed incorrectly!!"
            mess.textColor = UIColor.red
            currentPass.text = ""
            newPass.text = ""
            retypePass.text = ""
            mess.isHidden = false
            
        }else{
            
            
            if ((newPass.text?.characters.count)! < 6){
            
                mess.text = "New password must be more than 6 letters!!"
                mess.textColor = UIColor.red
                newPass.text = ""
                retypePass.text = ""
                mess.isHidden = false
                
            }else{
                
                if (newPass.text == retypePass.text){
                    
                    let headers: HTTPHeaders = [
                        "Authorization": "Bearer " + Constant.token,
                        "Content-Type": "application/json"
                    ]
                    
                    let parameters: [String: Any] = [
                        "oldPassword": currentPass.text ,
                        "newPassword":newPass.text
                        ]
                    
                    Alamofire.request(Constant.URLchangepass, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                        
                        let code = response.response?.statusCode
                        if (code == 200){
                            self.mess.text = "Your password is changed successfully!!"
                            self.mess.textColor = UIColor.blue
                            self.newPass.text = ""
                            self.currentPass.text = ""
                            self.retypePass.text = ""
                            self.mess.isHidden = false
                        }
                        let JSON = response.result.value
                        print(JSON)

                    }
                    
                }else{
                    
                    mess.text = "Your retype password is typed unmatch!!"
                    mess.textColor = UIColor.red
                    newPass.text = ""
                    retypePass.text = ""
                    mess.isHidden = false
                    
                }
            }
        }
    }
    

}
