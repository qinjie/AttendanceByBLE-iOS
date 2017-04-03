//
//  HistoryView.swift
//  ATK_BLE
//
//  Created by xuhelios on 3/31/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import UIKit

class HistoryView: UITableViewController {

    fileprivate let cellId = "cell"
    
    var histories : [History]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "History"
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        
        histories = GlobalData.history
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
 
        guard let cell = tableView.cellForRow(at: indexPath) as? LessonCell else { return }
        
      
        
    }
    
}
