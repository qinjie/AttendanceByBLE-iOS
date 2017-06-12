//
//  HistoryView.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/31/17.
//  Copyright © 2017 beacon. All rights reserved.
//
import Alamofire
import UIKit
import SwiftyJSON

class HistoryView: BaseTableViewController {

    fileprivate let cellId = "cell"
    
    var histories = [History]()
    let cellID = "LessonTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "History"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(UINib.init(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.separatorColor = UIColor.seperatorApp
        
        histories = GlobalData.history
        
        refreshControl = UIRefreshControl()
        refreshControl?.tintColor = UIColor.mainApp
        refreshControl?.addTarget(self, action: #selector(HistoryView.reloadData), for: .valueChanged)
        tableView.addSubview(refreshControl!)
        
    }
    
    func reloadData() {
        let token = UserDefaults.standard.string(forKey: "token")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + token!
            // "Accept": "application/json"
        ]
        
        Alamofire.request(Constant.URLhistory, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            let json = JSON.init(data: response.data!)
            NSLog("History   \(json)")
            self.refreshControl?.endRefreshing()
            if let JSON = response.result.value as? [[String:AnyObject]]{
                var tmp = [History]()
                for json in JSON {
                    let x = History()
                    x.name = json["lesson_name"] as! String
                    x.total = json["total"] as! Int
                    x.absent = json["absented"] as! Int
                    x.present = json["presented"] as! Int
                    tmp.append(x)
                }
                GlobalData.history = tmp
            }
            
            DispatchQueue.main.async {
                self.histories = GlobalData.history
                self.tableView.reloadData()
            }
            
        }
        

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return histories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100.0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryCell
        
        let lesson = histories[indexPath.row]
        cell.name.text = lesson.name
        cell.total.text = lesson.total.description
        cell.absent.text = lesson.absent.description
        cell.present.text = lesson.present.description
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell else { return }
        
    }
    
    @IBAction func loadHistory(_ sender: Any) {
    
          }
    
}
