//
//  TeenModeViewController.swift
//  Yippi
//
//  Created by Kit Foong on 11/03/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
class TeenModeViewController: TSViewController {
    @IBOutlet weak var teenModeTitle: UILabel!
    @IBOutlet weak var teenModeDescription1: UILabel!
    @IBOutlet weak var teenModeDescription2: UILabel!
    @IBOutlet weak var teenModeDescription3: UILabel!
    @IBOutlet weak var teenModeDescription4: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var footerLabel: UILabel!
    
    var onGetSecurityPin: ((String) -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        setUI()
    }
    
    func setUI() {
        proceedButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        proceedButton.setTitleColor(AppTheme.white, for: .normal)
        proceedButton.backgroundColor = TSColor.main.theme
        proceedButton.clipsToBounds = true
        proceedButton.addTarget(self, action: #selector(proceedAction), for: .touchUpInside)
        
        updateTeenUI()
        
        teenModeDescription1.text = "teen_mode_description_one".localized
        teenModeDescription2.text = "teen_mode_description_two".localized
        teenModeDescription3.text = "rw_teen_mode_description_three".localized
        teenModeDescription4.text = "rw_teen_mode_description_four".localized
        footerLabel.text = "teen_mode_footer".localized
        
        teenModeDescription1.textColor = UIColor(hex: 0x808080)
        teenModeDescription2.textColor = UIColor(hex: 0x808080)
        teenModeDescription3.textColor = UIColor(hex: 0x808080)
        teenModeDescription4.textColor = UIColor(hex: 0x808080)
        footerLabel.textColor = UIColor(hex: 0x808080)
    }
    
    func updateTeenUI() {
        teenModeTitle.text = UserDefaults.teenModeIsEnable ? "teen_mode_title_enabled".localized : "teen_mode_title_not_enabled".localized
        proceedButton.setTitle(UserDefaults.teenModeIsEnable ? "disable_teen_mode".localized : "enable_teen_mode".localized, for: .normal)
    }
    
    @objc func proceedAction() {
        let vc = TeenPinViewController()
        vc.onGetSecurityPin = { [weak self] code in
            guard let self = self else { return }
            self.updateTeenUI()
            self.proceedButton.isUserInteractionEnabled = false
            self.showToast(with: UserDefaults.teenModeIsEnable ? "teen_mode_title_enabled".localized : "teen_mode_title_not_enabled".localized, desc: "")
            NotificationCenter.default.post(name: Notification.Name.DashBoard.teenModeChanged, object: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.onGetSecurityPin?(code)
                self.navigationController?.popViewController(animated: true)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
