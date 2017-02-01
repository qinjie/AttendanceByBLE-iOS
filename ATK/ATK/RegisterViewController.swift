//
//  RegisterViewController.swift
//  ATKdemo
//
//  Created by xuhelios on 11/26/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var repeatPassTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func RegisterButtonTapped(_ sender: Any) {
        let username = usernameTextField.text
        let password = passTextField.text
        let repeatPass = repeatPassTextField.text
        
        // check empty field
        
        if ((username?.isEmpty)! || (password?.isEmpty)! || (repeatPass?.isEmpty)!){
            
            //display alert mess
            
            displayMyAlertMessage(mess: "All fields are required")
            return
        }
        
        //check match password
        
        if (!(password == repeatPass)){
            
            displayMyAlertMessage(mess: "Password is not matched")
            return
        }
        
        //store data
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(password, forKey: "password")
        UserDefaults.standard.synchronize()
        
        //display alert mess with confirmation
        var myAlert = UIAlertController(title: "Alert", message: "Successfull!!", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default){
            action in self.dismiss(animated: true, completion: nil)
            
        }
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
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
    
    func displayMyAlertMessage(mess : String){
        
        var myAlert = UIAlertController(title: "Alert", message: mess, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default, handler: nil)
        
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
}
