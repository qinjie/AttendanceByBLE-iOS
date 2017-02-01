//
//  MasterViewController.swift
//  ATK
//
//  Created by xuhelios on 12/28/16.
//  Copyright © 2016 xuhelios. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    @IBOutlet weak var tlb: UILabel!
    
    @IBOutlet weak var contentView: Ex2Controller!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  let controller = self.storyboard?.instantiateViewController(withIdentifier: "Ex2Controller") as! Ex2Controller
        
        contentView  =  self.storyboard?.instantiateViewController(withIdentifier: "Ex2Controller") as! Ex2Controller
        self.tlb.text = "abc"
        //        self.navigationController?.pushViewController(controller, animated: true)

        // Do any additional setup after loading the view.
    }

    @IBAction func `switch`(_ sender: Any) {
        self.contentView.setlb(x: self.tlb.text!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!)
//    {
//        if (segue.identifier == "testSegue")
//        {
//            //feed = segue!.destinationViewController as! Feed
//            let exController = segue.destination  as! Ex2Controller
//            exController.lb = self.tlb
//        }
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
