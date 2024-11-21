//
//  RedPacketBottomSheetVC.swift
//  Yippi
//
//  Created by Wong Jin Lun on 19/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

protocol RedPacketBottomSheetDelegate: class {
    func sendData(type: ModeType)
}

class RedPacketBottomSheetVC: TSViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var redPacketMode : [ModeType] = [.random, .identical, .specific]
    weak var delegate: RedPacketBottomSheetDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.roundCorners([.topLeft, .topRight], radius: 10)
        
        tableView.register(UINib.init(nibName: "RedPacketBottomSheetCell", bundle: nil),
                           forCellReuseIdentifier: RedPacketBottomSheetCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.setTitleColor(.gray, for: .normal)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let roundCornerPath = UIBezierPath(roundedRect: view.bounds,
                                           byRoundingCorners: [.topLeft , .topRight],
                                           cornerRadii: CGSize(width: 16, height: 16))
        let roundCornerMask = CAShapeLayer()
        roundCornerMask.frame = view.bounds
        roundCornerMask.path = roundCornerPath.cgPath
        view.layer.mask = roundCornerMask
       
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RedPacketBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RedPacketBottomSheetCell.cellIdentifier, for: indexPath) as! RedPacketBottomSheetCell
        cell.configure(title: redPacketMode[indexPath.row].value)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redPacketMode.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate.sendData(type: redPacketMode[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
