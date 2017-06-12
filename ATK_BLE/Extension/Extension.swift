//
//  Extension.swift
//  ATK_BLE
//
//  Created by Anh Tuan on 6/9/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func displayMyAlertMessage(title: String, mess : String){
        
        var myAlert = UIAlertController(title: title, message: mess, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK!!", style: UIAlertActionStyle.default, handler: nil)
        
        // okAction.setValue(image, forKey: "image")
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        imageView.image = UIImage(named: "warn")
        myAlert.view.addSubview(imageView)
        
        myAlert.addAction(okAction)
        
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
}
