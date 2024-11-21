//
//  IMJionTeamViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/23.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD
import NIMSDK
class IMJionTeamViewController: TSViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var jionBtn: UIButton!
    @IBOutlet weak var teamId: UILabel!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var notNowButton: UIButton!
    
    var joinTeam: NIMTeam!
    
    init(team: NIMTeam){
        super.init(nibName: nil, bundle: nil)
        joinTeam = team
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "joingroup".localized
        self.teamName.text = self.joinTeam.teamName
        if let team = self.joinTeam, let teamId = team.teamId {
            self.teamId.text = "group_number".localized + teamId
        }
        
        imageView.sd_setImage(with: URL(string: self.joinTeam.thumbAvatarUrl ?? ""), placeholderImage: UIImage.set_image(named: "ic_rl_default_group"), options: [.continueInBackground], completed: nil)
        
        self.jionBtn.setBackgroundColor(TSColor.main.theme, for: .normal)
        self.jionBtn.layer.masksToBounds = true
        self.jionBtn.layer.cornerRadius = 20
        self.jionBtn.setTitleColor(.white, for: .normal)
        
        
        if self.joinTeam.joinMode == .rejectAll {
            self.jionBtn.setTitle("not_allowed_to_join".localized, for: .normal)
            self.jionBtn.isUserInteractionEnabled = false
        } else {
            self.jionBtn.setTitle("text_request_to_join".localized, for: .normal)
        }
        
        self.jionBtn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 14)
        
        self.notNowButton.setTitleColor(TSColor.main.theme, for: .normal)
        self.notNowButton.setTitle("text_not_now".localized, for: .normal)
        self.notNowButton.titleLabel?.font = UIFont.systemMediumFont(ofSize: 14)
    }
    
    
    @IBAction func joinTeamAction(_ sender: UIButton) {
        self.joinTeam(teamId: self.joinTeam.teamId, message: "")
    }
    
    @IBAction func notNowAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func joinTeam(teamId: String?, message: String?){
        guard let teamID = self.joinTeam.teamId else {
            return
        }
        SVProgressHUD.show()
        NIMSDK.shared().teamManager.apply(toTeam: teamID, message: message ?? "") {[weak self] (error, applyStatus) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showError(message: error.localizedDescription)
                return
            }
            
            switch applyStatus {
            case .alreadyInTeam:
                let session = NIMSession.init(teamID, type: .team)
                let vc = IMChatViewController(session: session, unread: 0)
                if let navController = self?.navigationController {
                   var stack = navController.viewControllers
                   stack.remove(at: stack.count - 1)
                   stack.insert(vc, at: stack.count)
                   navController.setViewControllers(stack, animated: true)
                }
                //self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .waitForPass:
                self?.showError(message: "apply_success_awaiting_verification".localized)
                self?.navigationController?.popViewController(animated: true)
                break
            default:
                break
            }
        }
    }
}
