//
//  InputLocalContainer.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/10.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

class InputLocalContainer: UIView {
    private lazy var fTableView : UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height - 44 - TSBottomSafeAreaHeight), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = 50
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "InputLocalContainerCell", bundle: nil), forCellReuseIdentifier: InputLocalContainerCell.cellIdentifier)
        tableView.register(UINib(nibName: "InputNearLocalContainerCell", bundle: nil), forCellReuseIdentifier: InputNearLocalContainerCell.cellIdentifier)
        return tableView
    }()
    
    public typealias compliteHandler = (_ isSend: Bool, _ title: String, _ coordinate: CLLocationCoordinate2D) -> Void
    var callBackHandler: compliteHandler?
    var bottomView = UIView()
    var localBtn = UIButton()
    var sendBtn = UIButton()
    var dataArray = [TSPostLocationObject]()
    var selectIndexPath = IndexPath(row: 0, section: 0)
    var locationName = ""
    
    init(frame: CGRect, callBackHandler: compliteHandler?) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.callBackHandler = callBackHandler
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        LocationManager.shared.onLocationUpdate = { [weak self] in
            guard let self = self else { return }
            self.getLocaltionData()
        }
        
        self.addSubview(self.fTableView)
        self.bottomView.backgroundColor = .white
        self.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.height.equalTo(44)
            make.bottom.equalTo(-TSBottomSafeAreaHeight)
        }
        
        bottomView.addSubview(localBtn)
        localBtn.setImage(UIImage.set_image(named: "glyphsSearch"), for: .normal)
        localBtn.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(16)
            // make.width.equalTo(60)
            make.height.equalToSuperview()
        }
        
        //        bottomView.addSubview(sendBtn)
        //        sendBtn.setTitle("发送".localized, for: .normal)
        //        sendBtn.setTitleColor(.white, for: .normal)
        //        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        //        sendBtn.roundCorner(14)
        //        sendBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
        //        sendBtn.snp.makeConstraints { (make) in
        //            make.top.equalTo(8)
        //            make.width.equalTo(53)
        //            make.height.equalTo(28)
        //            make.right.equalTo(-12)
        //        }
        //        sendBtn.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        localBtn.addTarget(self, action: #selector(localAction), for: .touchUpInside)
    }
    
    @objc func localAction() {
        self.callBackHandler!(false, "", LocationManager.shared.locationCoordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }
    
    //send
    @objc func sendAction() {
        if self.dataArray.count == 0 {
            return
        }
        
        if var myCoordinate = LocationManager.shared.locationCoordinate {
            let section = self.selectIndexPath.section
            let row = self.selectIndexPath.row
            if section == 0 {
                let data = self.dataArray.first
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data?.locationLatitude ?? 0), longitude: CLLocationDegrees(data?.locationLatitude ?? 0))
                locationName = data?.locationName ?? ""
            }else{
                let data = self.dataArray[row + 1]
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data.locationLatitude ), longitude: CLLocationDegrees(data.locationLatitude ))
                locationName = data.locationName
            }
            self.callBackHandler!(true, locationName, myCoordinate)
        }
    }
    
    func getLocaltionData() {
        if let myCoordinate = LocationManager.shared.locationCoordinate {
            TSLocationsSearchNetworkManager().searchLocations(queryString: "", lat: myCoordinate.latitude, lng: myCoordinate.longitude) { [weak self] (locations, message) in
                guard let location = locations else { return }
                
                DispatchQueue.main.async {
                    self?.dataArray = location
                    self?.fTableView.reloadData()
                }
            }
        }
    }
}

extension InputLocalContainer : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            return 0
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.dataArray.count == 0 {
                return 0
            }
            return 1
        }
        if self.dataArray.count <= 1 {
            return 0
        }
        return  self.dataArray.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: InputNearLocalContainerCell.cellIdentifier, for: indexPath) as! InputNearLocalContainerCell
            cell.selectionStyle = .none
            cell.setData(data: self.dataArray[indexPath.row + 1])
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: InputLocalContainerCell.cellIdentifier, for: indexPath) as! InputLocalContainerCell
        cell.selectionStyle = .none
        
        cell.setData(data: self.dataArray.first)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let temIndex = self.selectIndexPath
        //        self.selectIndexPath = indexPath
        if var myCoordinate = LocationManager.shared.locationCoordinate {
            let section = indexPath.section
            let row = indexPath.row
            if section == 0 {
                let data = self.dataArray.first
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data?.locationLatitude ?? 0), longitude: CLLocationDegrees(data?.locationLongtitude ?? 0))
                locationName = data?.locationName ?? ""
            }else{
                let data = self.dataArray[row + 1]
                myCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(data.locationLatitude ), longitude: CLLocationDegrees(data.locationLongtitude ))
                locationName = data.locationName
            }
            self.callBackHandler!(true, locationName, myCoordinate)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: self.width, height: 30)
        let name = UILabel()
        name.text = "your_current_location".localized
        name.textColor = UIColor(red: 195, green: 195, blue: 195)
        name.setFontSize(with: 12, weight: .norm)
        name.frame = CGRect(x: 12, y: 0, width: 150, height: 30)
        view.addSubview(name)
        if section > 0 {
            name.text = "nearby_location".localized
        }
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
