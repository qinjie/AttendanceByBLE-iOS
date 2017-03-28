//
//  ChangePassController.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/24/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class ChangePassController: UIViewController {

    @IBOutlet weak var currentPass: UITextField!
    
    @IBOutlet weak var newPass: UITextField!
    
    @IBOutlet weak var retypePass: UITextField!
    
    @IBOutlet weak var mess: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    mess.text = "Your password is changed successfully!!"
                    mess.textColor = UIColor.blue
                    newPass.text = ""
                    currentPass.text = ""
                    retypePass.text = ""
                    mess.isHidden = false
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
