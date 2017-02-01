//
//  Ex2Controller.swift
//  ATK
//
//  Created by xuhelios on 12/28/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit

class Ex2Controller: UIViewController {

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lb.text = "xyz"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setlb(x: String){
        self.lb.text = "123"
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
