//
//  FilesPreviewTableViewController.swift
//  Yippi
//
//  Created by Tinnolab on 10/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import Foundation
import NIMSDK

class FilesPreviewTableViewController: TSTableViewController {
    
    
    let filesObjects: [NIMFileObject]
    var sortedFilesObjects: [String:[NIMFileObject]] = [:]
    var documentPreview: UIDocumentInteractionController!
    
    init(filesObjects: [NIMFileObject]) {
        self.filesObjects = filesObjects
        self.sortedFilesObjects = Dictionary(grouping: filesObjects) {($0.message?.timestamp.keyForPreviewObject() ?? "")}
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FilesPreviewTableViewCell.nib(), forCellReuseIdentifier: FilesPreviewTableViewCell.cellIdentifier)
        tableView.mj_header = nil
        tableView.mj_footer = nil
        tableView.estimatedRowHeight = 100
    }
}

// MARK: - Table view data source
extension FilesPreviewTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sortedFilesObjects.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let key = self.getKey(section)
        return self.sortedFilesObjects[key]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilesPreviewTableViewCell.cellIdentifier, for: indexPath) as! FilesPreviewTableViewCell
        let section = indexPath.section
        let row = indexPath.row
        let key = self.getKey(section)
        if let dataObj: NIMFileObject = self.sortedFilesObjects[key]?[row] {
            cell.UISetup(fileObject: dataObj)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 45))
        let titleLbl = UILabel(frame: CGRect(x: 10, y: 0, width: ScreenWidth - 20, height: 45))
        titleLbl.text = self.getKey(section)
        titleLbl.font = UIFont.systemFont(ofSize: 15)
        headerView.addSubview(titleLbl)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let key = self.getKey(section)
        if let dataObj: NIMFileObject = self.sortedFilesObjects[key]?[row], let path = dataObj.path {
            if FileManager.default.fileExists(atPath: path) {
                documentPreview = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
                documentPreview.name = dataObj.displayName
                documentPreview.delegate = self
                documentPreview.presentPreview(animated: true)
            } else {
                let vc: IMFilePreViewController = IMFilePreViewController(object: dataObj)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func getKey(_ section: Int) -> String {
        let keys = Array(self.sortedFilesObjects.keys).sorted(by: >)
        return keys[section]
    }
}

extension FilesPreviewTableViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentPreview = nil
    }
    
}

extension TimeInterval {
    
    func keyForPreviewObject() -> String {
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: self)
        let now = Date()
        let components = Set<Calendar.Component>([.year, .month, .day])

        let dateComponents = calendar.dateComponents(components, from: date)
        let nowComponents = calendar.dateComponents(components, from: now)
        
        var key = ""
        if (dateComponents.year == nowComponents.year && dateComponents.month == nowComponents.month && dateComponents.weekOfMonth == nowComponents.weekOfMonth) {
            key = "this_week".localized
        } else {
            if let year = dateComponents.year, let month = dateComponents.month {
                key = String(format: "year_month".localized, year, month)
            }
        }
        return key
    }
}
