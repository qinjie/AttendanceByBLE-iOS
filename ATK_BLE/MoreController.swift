//
//  MoreController.swift
//  Attandence Taking System
//
//  Created by KyawLin on 5/21/17.
//  Copyright © 2017 KyawLin. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class MoreController: UIViewController {
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myImageView.image = UIImage(named: "student")
        username.text = UserDefaults.standard.string(forKey: "name")
        email.text = UserDefaults.standard.string(forKey: "email")
        address.text = UserDefaults.standard.string(forKey: "address")
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(self)
        UserDefaults.standard.removeObject(forKey: "student_id")
        UserDefaults.standard.set("-", forKey: "email")
        UserDefaults.standard.set("-", forKey: "address")
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + UserDefaults.standard.string(forKey: "token")!
        ]
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width*0.5, y: UIScreen.main.bounds.size.height*0.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        self.view.addSubview(spinnerIndicator)
        Alamofire.request(Constant.URLlogout, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            let code = response.response?.statusCode
            spinnerIndicator.stopAnimating()
            print("done")
            if code == 200{
                self.performSegue(withIdentifier: "sign out", sender: nil)
            }
            else{
                let alertController = UIAlertController(title: "Sign Out", message: "Error signing out", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
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
