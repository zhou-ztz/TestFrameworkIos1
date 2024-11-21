//
//  IMSessionLocalHistoryViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/5/24.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate
class IMSessionLocalHistoryViewController: BaseViewController {
    
    var session: NIMSession!
    
//    override init(session: NIMSession) {
//        self.session = session
//        super.init(session: session)
//    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let object : NTESSearchLocalHistoryObject = self.data[indexPath.row] as! NTESSearchLocalHistoryObject
//        if object.type.rawValue == 0 {
//            self.data.removeAllObjects()
//            let option = NIMMessageSearchOption()
//            option.searchContent = self.keyWord
//            let uids = self.searchUsers(byKeyword: self.keyWord, users:self.members)
//            option.fromIds       = uids as! [String]
//            option.limit         = 10
//            option.order         = NTESBundleSetting.sharedConfig()!.localSearchOrderByTimeDesc() ? .desc : .asc
//            option.allMessageTypes = true
//            self.lastOption      = option
//            self.showSearchData(option, loadMore:true)
//           
//            
//        }else{
//            let vc = IMSessionHistoryViewController(session: self.session, message: object.message)
//            self.navigationController?.pushViewController(vc, animated: false)
//        }
//        
//    }
    
    

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
