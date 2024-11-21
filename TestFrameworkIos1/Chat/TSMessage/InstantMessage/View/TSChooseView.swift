//
//  TSChooseView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/3.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

protocol TSChooseViewDelegate: class {
    
    func didSelectItem(indexPath: IndexPath, type: ChooseViewType)
}

enum ChooseViewType: Int {
    case scan          = 1
    case nearBy        = 2
    case contact       = 3
    case groupInvate   = 4
    case note          = 5
    case collection    = 6
    case newChat       = 7
}

class ChooseViewModel: NSObject {
    var title: String
    var image: String
    var type:  ChooseViewType
    
    init(title: String, image: String, type: ChooseViewType) {
        self.title = title
        self.image = image
        self.type  = type
        super.init()
    }
}

class TSChooseView: UIControl {
    public weak var delegate: TSChooseViewDelegate!
    
    public var dataArray = [ChooseViewModel]()
    public var imageArray = [String]()
    var msgCount: Int = 0
    var groupInvateCount: Int = 0
    var closeBlock: (()->())?
    let scale : CGFloat = 0.6
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: self.width - 208, y: self.height - TSTabbarHeight - 48 * CGFloat(self.dataArray.count) - 72 - 8, width: 192 , height: 48 * CGFloat(self.dataArray.count)), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 48
        tableView.backgroundColor = UIColor(red: 74, green: 74, blue: 74)
        tableView.register(UINib(nibName: "TSChooseViewCell", bundle: nil), forCellReuseIdentifier: TSChooseViewCell.cellIdentifier)
        tableView.roundCorner(3)
        tableView.alpha = 0
        tableView.bounces = false
        
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }
    
    func setUI(){
        self.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        let titles = ["scan_qr".localized, "people_nearby".localized, "contact".localized, "title_notification_team".localized, "message_request_title".localized, "title_favourite_message".localized, "new_chat_title".localized]
        let images = ["scan", "nearby", "contact", "groupInvitation", "messageRequest", "msgCollection", "newChat"]
        for i in 0 ..< titles.count {
            let model = ChooseViewModel(title: titles[i], image: images[i], type: ChooseViewType(rawValue: i + 1)!)
            dataArray.append(model)
        }

        self.addSubview(self.tableView)
        let frame = self.tableView.frame
        //设置中心点 （0，0）左上角，（0，1）左下角，（1， 0）右上，（1，1）右下
        self.tableView.layer.anchorPoint = CGPoint(x: 1, y: 1)
        self.tableView.frame = frame
        //先缩小
        let transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        tableView.transform = transform
        self.showTB()
    }
    
    func showTB(){
        let transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 0.15, delay: 0.0, options: [], animations: { [weak self] in
            self?.tableView.alpha = 1
            self?.tableView.transform = transform
            
        }) { (_) in
            
        }
    }
    
    public func dismissView(){
        self.closeAction()
    }
    
    @objc func closeAction(){
        let transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        UIView.animate(withDuration: 0.15, delay: 0.0, options: [.curveEaseOut], animations: { [weak self] in
            self?.tableView.alpha = 0
            self?.tableView.transform = transform
        }) { (_) in
            self.removeFromSuperview()
        }
        self.closeBlock!()
    }
    
    public func relaodCount(msgCount: Int, groupInvateCount: Int){
        self.msgCount = msgCount
        self.groupInvateCount = groupInvateCount
        tableView.reloadData()
    }
}

extension TSChooseView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TSChooseViewCell.cellIdentifier, for: indexPath) as! TSChooseViewCell
        cell.selectionStyle = .none
        cell.titleLab.text = self.dataArray[indexPath.row].title
        cell.icon.image = UIImage.set_image(named: self.dataArray[indexPath.row].image)
        cell.redLab.isHidden = true
        if indexPath.row == 3 {
            cell.redLab.isHidden = groupInvateCount == 0
        }
        if indexPath.row == 4 {
            cell.redLab.isHidden = msgCount == 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row]
        self.delegate.didSelectItem(indexPath: indexPath, type: model.type)
    }
    
}
