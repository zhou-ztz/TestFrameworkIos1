//
//  IMMigrateMessageViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/22.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import SVProgressHUD
//import NIMPrivate

class IMMigrateMessageViewController: TSViewController {
    
    var data = [String]()
   
    lazy var tableView: UITableView = {
        let tb = UITableView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight), style: .grouped)
        tb.rowHeight = 44
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.showsVerticalScrollIndicator = false
        tb.separatorStyle = .none
        tb.delegate = self
        tb.dataSource = self
        tb.sectionIndexBackgroundColor = .clear
        tb.backgroundColor = UIColor(hex: 0xf4f5f5)
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setCloseButton(backImage: true, titleStr: "setting_backup_migrate_chat".localized)
        self.view.backgroundColor =  .white
        self.data = ["backup_migrate_chat_export".localized, "backup_migrate_chat_import".localized]
        self.view.addSubview(tableView)
    }
    
    func onTouchExportLocalMessages(){
        
//        let alertController = UIAlertController(title: "title_export_message_confirmation".localized, message: "backup_migrate_chat_confirmation".localized, preferredStyle: .alert)
//        let actionCancel = UIAlertAction(title: "cancel".localized, style: .default) { (action) in
//            alertController.dismiss(animated: true, completion: nil)
//        }
//        
//        let actionExport = UIAlertAction(title: "backup_migrate_chat_continue_export".localized, style: .default) { (action) in
//            let vc = NTESExportMessageViewController()
//            let nav = UINavigationController(rootViewController: vc)
//            self.present(nav, animated: true, completion: nil)
//
//        }
//        alertController.addAction(actionCancel)
//        alertController.addAction(actionExport)
//        self.present(alertController, animated: true, completion: nil)
    }

    func onTouchImportLocalMessages(){
        SVProgressHUD.show()
        NIMSDK.shared().conversationManager.fetchMigrateMessageInfo { [weak self] (error, remoteFilePath, secureKey) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showError(message: error.localizedDescription)
                return
            }
            
            guard let filePath = remoteFilePath else {
                self?.showError(message: "backup_migrate_chat_import_msg_empty".localized)
                return
            }
            
            self?.getHistorySuccessWithRemotePath(remotePath: filePath, secureKey: secureKey ?? "")
        }
        
    }

    func getHistorySuccessWithRemotePath(remotePath: String, secureKey: String) {
//        let vc = NTESImportMessageViewController()
//        vc.remoteFilePath = remotePath
//        vc.secureKey = secureKey
//        let nav = UINavigationController(rootViewController: vc)
//        self.present(nav, animated: true, completion: nil)
    }

   
    
}

extension IMMigrateMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.onTouchExportLocalMessages()
        }else{
            self.onTouchImportLocalMessages()
        }
    }
}
