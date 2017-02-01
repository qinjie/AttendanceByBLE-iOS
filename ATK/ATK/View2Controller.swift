//
//  View2Controller.swift
//  ATK
//
//  Created by xuhelios on 12/28/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit

class View2Controller: UITabBarController {

    
    override func viewDidLoad() {
    super.viewDidLoad()
    //self.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tabBar.invalidateIntrinsicContentSize()
        var tabSize: CGFloat = 44.0
        var orientation = UIApplication.shared.statusBarOrientation
        
        if UIInterfaceOrientationIsLandscape(orientation) {
            tabSize = 18.0
            }
        
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = tabSize
        tabFrame.origin.y = self.view.frame.origin.y
        
        
        
        self.tabBar.frame = tabFrame
        
        
        self.tabBar.isTranslucent = false
        self.tabBar.isTranslucent = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
