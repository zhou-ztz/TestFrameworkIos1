//
//  MessageCollectCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

protocol MessageCollectDelegate: class{
    func checkBoxClicked(model: FavoriteMsgModel)
}

class MessageCollectCell: UITableViewCell {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    var msgContentView: BaseCollectView?
    static let cellIdentifier = "MessageCollectCell"
    weak var delegate: MessageCollectDelegate?
    var model: FavoriteMsgModel?
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                checkBoxButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.normal)
            } else {
                checkBoxButton.setImage(UIImage.set_image(named: "ic_checkbox_normal"), for: UIControl.State.normal)
            }
        }
    }
    
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        self.setUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUI(){
        lineView.backgroundColor = UIColor(hex: 0xF5F5F5)
        checkBoxButton.setTitle("", for: .normal)
        checkBoxButton.addTarget(self, action: #selector(checkBoxAction), for: .touchUpInside)
        checkBoxButton.imageView?.contentMode = .scaleAspectFit
        checkBoxButton.isHidden = true
        isChecked = false
    }
    
    func dataUpdate(dataModel: FavoriteMsgModel, collectView: BaseCollectView) {
        if self.msgContentView != nil {
            self.msgContentView?.removeFromSuperview()
        }
        self.msgContentView = collectView
        self.baseView.layer.cornerRadius = 4
        self.baseView.layer.masksToBounds = true
        //self.msgContentView?.backgroundColor = .white
        self.baseView.addSubview(self.msgContentView!)
        self.msgContentView!.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(0)
        }
        model = dataModel
    }
    
    @objc func checkBoxAction (sender: UIButton){
        isChecked = !isChecked
        delegate?.checkBoxClicked(model: model!)
    }
    
}
