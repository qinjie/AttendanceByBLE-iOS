//
//  BaseViewController.swift
//  ATK_BLE
//
//  Created by Anh Tuan on 6/9/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.mainApp
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setBorderTxf(txf : UITextField){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.seperatorApp.cgColor
        border.frame = CGRect(x: 0, y: txf.frame.size.height - width, width:  txf.frame.size.width, height: 2)
        
        border.borderWidth = width
        txf.layer.addSublayer(border)
        txf.layer.masksToBounds = true
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
