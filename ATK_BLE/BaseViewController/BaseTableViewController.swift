//
//  BaseTableViewController.swift
//  ATK_BLE
//
//  Created by Anh Tuan on 6/9/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.mainApp
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20)]
        tableView.separatorColor = UIColor.seperatorApp
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
