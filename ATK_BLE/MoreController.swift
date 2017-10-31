//
//  MoreController.swift
//  ATK_BLE
//
//  Created by Kyaw Lin on 31/10/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class MoreController: UITableViewController {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var notifiactionLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mView: UIView!
    
    var stepperValue:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        tableView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.tableView.tableFooterView = UIView(frame:.zero)
        self.tableView.sectionHeaderHeight = 40
        self.tableView.allowsSelection = false
        
        stepperValue = Int(UserDefaults.standard.string(forKey: "notification time")!)!
        stepper.addTarget(self, action: #selector(stepperValueChanged(sender:)), for: .valueChanged)
        stepper.value = Double(Int(UserDefaults.standard.string(forKey: "notification time")!)!)
        stepper.minimumValue = 5
        stepper.maximumValue = 20
        stepper.stepValue = 5
        
        if let value = UserDefaults.standard.string(forKey: "notification time"){
            notifiactionLabel.text = "before \(value) mins"
        }
        
        if let name = UserDefaults.standard.string(forKey: "name"){
            username.text = name
        }else{
            username.text = ""
        }
        if let mEmail = UserDefaults.standard.string(forKey: "email"){
            email.text = mEmail
        }else{
            email.text = ""
        }
        if let mAddress = UserDefaults.standard.string(forKey: "address"){
            address.text = mAddress
        }else{
            address.text = ""
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signoutPressed(_ sender: UIButton) {
        NotificationCenter.default.removeObserver(UIApplication.shared.delegate!)
        UserDefaults.standard.removeObject(forKey: "student_id")
        UserDefaults.standard.set("-", forKey: "email")
        UserDefaults.standard.set("-", forKey: "address")
        self.performSegue(withIdentifier: "sign out", sender: nil)
    }
    
    @objc func stepperValueChanged(sender:UIStepper){
        let value = Int(sender.value)
        notifiactionLabel.text = "before \(value) mins"
        UserDefaults.standard.set(value, forKey: "notification time")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stepper changed"), object: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.textColor = UIColor.darkGray
        header.backgroundView?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
       // header.backgroundColor = UIColor.white
        
        let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.5))
        borderTop.backgroundColor = UIColor.lightGray
        
        let borderBottom = UIView(frame: CGRect(x: 0, y: header.bounds.height, width: tableView.bounds.size.width, height: 0.5))
        borderBottom.backgroundColor = UIColor.lightGray
        header.addSubview(borderBottom)
        
        if section > 0 {
            header.addSubview(borderTop)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            cell.separatorInset = UIEdgeInsets.zero
        }
    
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
