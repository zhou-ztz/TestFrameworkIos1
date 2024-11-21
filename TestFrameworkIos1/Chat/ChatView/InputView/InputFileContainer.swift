//
//  InputFileContainer.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/10.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


class InputFileContainer: UIView {

    private lazy var fTableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height - 44 - TSBottomSafeAreaHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 61
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "InputFileContainerCell", bundle: nil), forCellReuseIdentifier: InputFileContainerCell.cellIdentifier)
        return tableView
    }()
    
    lazy var footView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height - 44 - TSBottomSafeAreaHeight - 30))
        view.backgroundColor = .white
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "25")
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(72)
            make.top.equalTo(48)
        }
        
        let title = UILabel()
        title.text = "file_empty_state".localized
        title.textColor = UIColor(red: 195, green: 195, blue: 195)
        title.setFontSize(with: 12, weight: .norm)
        title.textAlignment = .center
        view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(119)
        }
        
        return view
    }()
    
    var bottomView = UIView()
    var fileBtn = UIButton()
    var dataArray = [[String: Any]]()
   
    public typealias compliteHandler = (_ isSend: Bool,  _ url: URL?) -> Void
    var callBackHandler: compliteHandler?
    init(frame: CGRect , callBackHandler: compliteHandler?) {
        super.init(frame: frame)
        self.callBackHandler = callBackHandler
        self.backgroundColor = .white
        setUpUI()
        NotificationCenter.default.add(observer: self, name: NSNotification.Name(rawValue: "FileContainerRelaod")) { [self] in
            self.getLocalFile()
            self.fTableView.reloadData()
            if self.dataArray.count == 0 {
                self.fTableView.tableFooterView = self.footView
            }else{
                self.fTableView.tableFooterView = UIView()
            }
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpUI(){
        self.addSubview(self.fTableView)
        self.bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(44)
            make.bottom.equalTo(-TSBottomSafeAreaHeight)
        }
        
        bottomView.addSubview(fileBtn)
        fileBtn.setTitle("phone_storage".localized, for: .normal)
        fileBtn.setTitleColor(UIColor(red: 59, green: 179, blue: 255), for: .normal)
        fileBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        fileBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
           // make.width.equalTo(60)
            make.height.equalToSuperview()
        }
        fileBtn.addTarget(self, action: #selector(fileAction), for: .touchUpInside)
        
       getLocalFile()
       fTableView.reloadData()
       
    }
    
    
    @objc func fileAction(){
        self.callBackHandler!(false, nil)
       
    }
   
    func getLocalFile(){
        dataArray.removeAll()
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        if !FileManager.default.fileExists(atPath: documentsPath + "/chatFile/") {
            try? FileManager.default.createDirectory(atPath: documentsPath + "/chatFile/", withIntermediateDirectories: true, attributes: nil)
        }
        let filesArray = try? FileManager.default.contentsOfDirectory(atPath: documentsPath + "/chatFile/" )
        
        if let arr = filesArray {
            for file in arr {
                let filePath = documentsPath + "/chatFile/" + file
                let properties = try! FileManager.default.attributesOfItem(atPath: filePath) as [FileAttributeKey : Any]
                let modDate = properties[FileAttributeKey.creationDate]
                let fileSize = properties[FileAttributeKey.size] as! UInt64
                let size = covertToFileString(with: fileSize)
                let dict = ["path": filePath, "date": modDate!, "fileSize": size] as [String : Any]
                dataArray.append(dict)

            }
        }
        
        
        // sort by creation date
        dataArray.sort { (s1, s2) -> Bool in
            let date1 = s1["date"] as? Date
            let date2 = s2["date"] as? Date
            if date1?.compare(date2!) == .orderedAscending
            {
                return false
            }
            
            if date1?.compare(date2!) == .orderedDescending
            {
                return true
            }

            return true

        }
        

    }
    
    
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
   
}
    


extension InputFileContainer : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InputFileContainerCell.cellIdentifier, for: indexPath) as! InputFileContainerCell
        cell.selectionStyle = .none
        cell.setFileData(data: dataArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = dataArray[indexPath.row]
        if let path = dict["path"] as? String {
            self.callBackHandler!(true, URL(fileURLWithPath: path))
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
        let name = UILabel()
        name.text = "recent_files".localized
        name.textColor = UIColor(red: 195, green: 195, blue: 195)
        name.setFontSize(with: 12, weight: .norm)
        name.frame = CGRect(x: 16, y: 0, width: 150, height: 30)
        view.addSubview(name)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
