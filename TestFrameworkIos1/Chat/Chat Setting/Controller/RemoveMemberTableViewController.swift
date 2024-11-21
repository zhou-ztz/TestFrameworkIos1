//
//  RemoveMemberTableViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 21/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage
import NIMSDK

protocol RemoveTeamMemberCellDelegate: class {
    func memberButtonClick(chatbutton: UIButton, model: NIMTeamMember)
}

class RemoveMemberTableViewController: TSChatFriendListViewController {
    var members: [NIMTeamMember] = []
    var searchMembers: [NIMTeamMember] = []
    
    var teamId: String
    
    var membersDidRemovedHandler: EmptyClosure?
    
    var isSearching = false
    
    init(_ teamId: String) {
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
        self.ischangeGroupMember = .delete
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if members.count == 0 {
            friendListTableView.show(placeholderView: .empty)
        } else {
            searchView.makeVisible()
        }
        self.friendListTableView.reloadData()
    }
    
    override func rightButtonClick() {
        chatItem?.isUserInteractionEnabled = false
        kickUsers()
    }
    
    func kickUsers() {
        let kickIds = (choosedDataSource as! [NIMTeamMember]).compactMap { $0.userId }
        
        NIMSDK.shared().teamManager.kickUsers(kickIds, fromTeam: teamId) { error in
            guard let _ = error else {
                let alert = TSIndicatorWindowTop(state: .success, title: "remove_member_success".localized)
                alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    self.membersDidRemovedHandler?()
                    self.navigationController?.popViewController(animated: true)
                })
                return
            }
            let alert = TSIndicatorWindowTop(state: .faild, title: "remove_member_failed".localized)
            alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? searchMembers.count : members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indentifier = "chatfiendlistcell"
        var cell = tableView.dequeueReusableCell(withIdentifier: indentifier) as? RemoveTeamMemberCell
        if cell == nil {
            cell = RemoveTeamMemberCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: indentifier)
        }
        cell?.currentChooseArray = choosedDataSource
        cell?.originData = originDataSource
        cell?.ischangeGroupMember = ischangeGroupMember
        cell?.selectionStyle = .none
        cell?.setMember(isSearching ? searchMembers[indexPath.row] : members[indexPath.row])
        cell?.removeDelegate = self
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: RemoveTeamMemberCell = tableView.cellForRow(at: indexPath) as! RemoveTeamMemberCell
        
        let member = isSearching ? searchMembers[indexPath.row] : members[indexPath.row]
        if choosedDataSource.contains(member) {
            choosedDataSource.remove(member)
        } else {
            choosedDataSource.add(member)
        }
        updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        cell.chatButton.isSelected = !cell.chatButton.isSelected
    }
    
    override func populateHeadImage(_ chooseArray: NSMutableArray) {
        for (index, model) in chooseArray.enumerated() {
            let member: NIMTeamMember = model as! NIMTeamMember
            
            let avatarImage = AvatarView(origin: CGPoint(x: index * (headerWidth + headerSpace) + headerSpace, y: (49 - headerWidth) / 2), type: .custom(avatarWidth: CGFloat(headerWidth), showBorderLine: false))
            avatarImage.avatarPlaceholderType = .unknown
            avatarImage.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: member.userId ?? "")
            
            let iconImage: UIImageView = UIImageView(frame: CGRect(x: avatarImage.left + avatarImage.frame.width * 0.65, y: avatarImage.top + avatarImage.frame.width * 0.65, width: avatarImage.frame.width * 0.35, height: avatarImage.frame.width * 0.35))
            iconImage.layer.masksToBounds = true
            iconImage.layer.cornerRadius = avatarImage.frame.width * 0.35 / 2.0
            
            switch member.type {
            case .owner:
                iconImage.image = UIImage.set_image(named: "icon_team_creator")
            case .manager:
                iconImage.image = UIImage.set_image(named: "icon_team_manager")
            default:
                iconImage.image = nil
                break
            }
            
            choosedScrollView.addSubview(avatarImage)
            choosedScrollView.addSubview(iconImage)
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchKeyword = textField.text {
            keyword = searchKeyword
            isSearching = !keyword.isEmpty
            
            var remarkArray = [NIMTeamMember]()
            
            if let userRemarkName =  UserDefaults.standard.array(forKey: "UserRemarkName") {
                let remarkNameArray = userRemarkName as! [[String:String]]
                let filteredArray = remarkNameArray.filter ({ $0["remarkName"]!.range(of: searchKeyword, options: .caseInsensitive) != nil })
                
                for remark in filteredArray {
                    let match = members.filter{ $0.userId == remark["username"] }.first
                    if match != nil {
                        remarkArray.append(match!)
                    }
                }
            }
            
            var items = members.filter {
                guard let userId = $0.userId else { return false }
                let name = NIMSDKManager.shared.getAvatarIcon(userId: userId).nickname ?? userId
                if !(name.lowercased().contains(searchKeyword.lowercased()) ?? false) {
                    return userId.lowercased().contains(searchKeyword.lowercased()) ?? false
                }
                return true
            }
            
            if items.count == 0 {
                for remark in remarkArray {
                    items.append(remark)
                }
            } else {
                for item in items {
                    for remark in remarkArray {
                        if remark.userId != item.userId {
                            items.append(remark)
                        }
                    }
                }
            }
            
            if items.count > 0 {
                occupiedView.isHidden = true
                searchMembers = items
                searchDataSource = NSMutableArray(array: items)
            } else {
                searchMembers.removeAll()
                searchDataSource.removeAllObjects()
                
                if !keyword.isEmpty {
                    friendListTableView.show(placeholderView: .empty)
                } else {
                    friendListTableView.removePlaceholderViews()
                }
            }
            friendListTableView.reloadData()
            return true
        }
        return true
    }
}

extension RemoveMemberTableViewController: RemoveTeamMemberCellDelegate {
    func memberButtonClick(chatbutton: UIButton, model: NIMTeamMember) {
        if chatbutton.isSelected {
            choosedDataSource.remove(model)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        } else {
            choosedDataSource.add(model)
            updateChoosedScrollViewUI(chooseArray: choosedDataSource)
        }
        chatbutton.isSelected = !chatbutton.isSelected
    }
}

class RemoveTeamMemberCell: TSChatChooseFriendCell {
    var memberInfo: NIMTeamMember? = nil
    weak var removeDelegate: RemoveTeamMemberCellDelegate?
    
    func setMember(_ member: NIMTeamMember) {
        memberInfo = member
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: member.userId ?? "")
        avatarImageView.avatarInfo = avatarInfo
        // 用户名
        if let userRemarkName =  UserDefaults.standard.array(forKey: "UserRemarkName") {
            let remarkNameArray = userRemarkName as! [[String:String]]
            let remarkName = remarkNameArray.filter { $0["username"] == "\(member.userId ?? "")"}.first
            
            if let remarkNameString = remarkName {
                nameLabel.text = remarkNameString["remarkName"]
            } else {
                nameLabel.text = avatarInfo.nickname
            }
        } else {
            nameLabel.text = avatarInfo.nickname
        }
        
        chatButton.isSelected = false
        // 设置默认的高亮选中的勾
        chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
        for (_, model) in currentChooseArray.enumerated() {
            let memberInfo: NIMTeamMember = model as! NIMTeamMember
            if memberInfo.userId == member.userId {
                chatButton.isSelected = true
                break
            }
        }
        // 设置特定的选项为不可选中的勾
        for (_, model) in originData.enumerated() {
            let memberInfo: NIMTeamMember = model as! NIMTeamMember
            if memberInfo.userId == member.userId {
                chatButton.isSelected = true
                chatButton.setImage(UIImage.set_image(named: "msg_box_choose_before"), for: UIControl.State.selected)
                break
            }
        }
    }
    
    override func changeButtonStatus() {
        removeDelegate?.memberButtonClick(chatbutton: chatButton, model: memberInfo!)
    }
}
