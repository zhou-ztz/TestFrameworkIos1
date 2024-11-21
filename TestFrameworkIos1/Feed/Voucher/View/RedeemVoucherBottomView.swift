//
//  RedeemVoucherBottomView.swift
//  RewardsLink
//
//  Created by Kit Foong on 20/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class RedeemVoucherBottomView: TSViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var models : [RedeemVoucherModel] = []
    var softpins : [Softpin] = []
    var activationTokenURL : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCloseButton(backImage: true, titleStr: "rw_redeem_voucher".localized)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        descriptionLabel.text = "rw_redeem_voucher_desc".localized.replacingOccurrences(of: "%s", with: models.count.stringValue)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(RedeemVoucherTableViewCell.nib(), forCellReuseIdentifier: RedeemVoucherTableViewCell.cellIdentifier)
        
        if softpins.isEmpty {
            models.append(RedeemVoucherModel(index: 1, content: [RedeemVoucherContent(title: "rw_url_link".localized, content: activationTokenURL)]))
        } else {
            for (index, element) in softpins.enumerated() {
                models.append(RedeemVoucherModel(index: index + 1, content: [RedeemVoucherContent(title: "rw_serial_number".localized, content: element.topupSerial),
                                                                             RedeemVoucherContent(title: "rw_code".localized, content: element.topupCode)]))
            }
        }
        
        tableView.reloadData()
        setupUI()
    }
}

extension RedeemVoucherBottomView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RedeemVoucherTableViewCell.cellIdentifier, for: indexPath) as? RedeemVoucherTableViewCell, let model = models[safe: indexPath.row]  {
            cell.set(content: model)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension RedeemVoucherBottomView: RedeemVoucherCellDelegate {
    func copy(_ content: String?) {
        if let content = content {
            UIPasteboard.general.string = content
            self.showTopFloatingToast(with: "", desc: "re_copy_successfully".localized)
        }
    }
    
    func share(_ content: String?) {
        if let content = content, let url = URL(string: content), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let toastView = SharedToastView()
            toastView.title = "rw_redeem_voucher_error_message".localized
            self.showTopFloatingToast(with: "", background: UIColor(hex: 0xFFD5D4), customView: toastView)
        }
    }
}
