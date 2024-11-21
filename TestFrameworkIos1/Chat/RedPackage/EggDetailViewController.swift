// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SnapKit
//EggDetailViewControllerType
class EggDetailViewController: TSViewController {
    @IBOutlet weak var redPacketFromLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var yippsAmountLabel: UILabel!
    @IBOutlet weak var yippsReceiverLabel: UILabel!
    @IBOutlet weak var eggView: UIView!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var topCurvedView: UIView!
    @IBOutlet weak var packetInfoLabel: UILabel!
    @IBOutlet weak var tableView: TSTableView!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    var info: ClaimEggResponse!
    var isSender: Bool = false
    var isGroup: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setClearNavBar(tint: TSColor.main.theme, shadowColor: .clear)
        self.navigationController?.navigationBar.tintColor = .white
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {
            UIApplication.shared.setStatusBarStyle(.darkContent, animated: true)
        } else {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        configureNavBar()
        configureView()
        mapData()
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        topCurvedView.addBottomRoundedEdge(desiredCurve: 3.0)
        topCurvedView.setGradientBackground(colorTop: AppTheme.blue, colorBottom: UIColor(hex: 0x007AFF), view: topCurvedView)
    }
    
    private func mapData() {
        /// User avatar and name
        avatarImageView.sd_setImage(with: URL(string: (info.sender.avatar?.url).orEmpty), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"))
        nameLabel.text = info.sender.name
        
        /// Wish note
        noteLabel.text = info.header.wishes
        noteLabel.isHidden = info.header.wishes.isEmpty
        
        /// Amount
        if isSender {
            yippsAmountLabel.text = info.header.amount
            if info.header.amount.orEmpty.isEmpty {
                amountView.makeHidden()
            } else {
                amountView.makeVisible()
            }
        } else {
            if let receiver = info.receivers.first(where: { $0.user.uid == CurrentUserSessionInfo?.userIdentity }), receiver.amount.toDouble() > 0.0 {
                yippsAmountLabel.text = receiver.amount
                amountView.makeVisible()
            } else {
                amountView.makeHidden()
            }
        }
        
        errorMessage.text = info.header.messages
        
        if info.header.messages.orEmpty.isEmpty {
            errorMessage.makeHidden()
        } else {
            errorMessage.makeVisible()
        }
        
        yippsReceiverLabel.text = info.header.yippsMsg
        
        if info.header.yippsMsg.orEmpty.isEmpty {
            yippsReceiverLabel.makeHidden()
        } else {
            yippsReceiverLabel.makeVisible()
        }
        
        var header: String
        
        if info.receivers.count > 0 {
            if isGroup {
                header = "rw_text_quantity_egg_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero - info.eggInfo.quantityRemaining.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
            } else {
                header = "rw_text_quantity_egg_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
            }
        } else {
            header = "rw_text_quantity_egg_not_redeemed".localized.replacingFirstOccurrence(of: "%1s", with: "\(info.eggInfo.quantity.orZero)").replacingFirstOccurrence(of: "%2s", with: info.eggInfo.amount.orEmpty)
        }
        
        packetInfoLabel.text = header
    }
    
    private func configureView() {
      
        avatarImageView.roundCorner(15)
        
        //errorMessage.applyStyle(.semibold(size: 20, color: UIColor.lightGray))
        
        redPacketFromLabel.text = "red_packet_from".localized
        
        packetInfoLabel.applyStyle(.regular(size: 12, color: .gray))
        
        disclaimerLabel.text = "viewholder_redpacket_refund".localized
        disclaimerLabel.font = UIFont.systemFont(ofSize: 12.0)
        disclaimerLabel.textColor = .gray
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReceiverTableCell.nib(), forCellReuseIdentifier: ReceiverTableCell.cellReuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    private func configureNavBar() {
        let leftItem = UIBarButtonItem(image: UIImage.set_image(named: "IMG_topbar_close")) { [weak self] in
            self?.close()
        }
        navigationItem.leftBarButtonItem = leftItem
    }
    
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table view delegate & data source
extension EggDetailViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.receivers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReceiverTableCell.cellReuseIdentifier) as! ReceiverTableCell
        let item = info.receivers[indexPath.row]
        cell.configureData(with: (item.user.avatar?.url).orEmpty, userId: item.user.uid, name: item.user.name, date: item.redeemTime, amount: item.amount, luckyStar: item.luckyStar ?? 0)
        return cell
    }
}
