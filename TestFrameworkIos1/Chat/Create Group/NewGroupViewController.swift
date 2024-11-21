//
//  NewGroupViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class NewGroupViewController: TSViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var newGroupLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        setLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    private func setupView() {
        
        view.backgroundColor = .white
        
        memberCountLabel.text = "7/10,000"
        memberCountLabel.textColor = .lightGray
        
        backButton.contentMode = .scaleAspectFit
        backButton.setTitle("", for: .normal)
        let image = UIImage.set_image(named: "back.png")?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(image, for: .normal)
        backButton.tintColor = .black
        
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowRadius = 5
        
        setTableView()
        setCollectionView()
    }
    
    private func setLanguage() {
        newGroupLabel.text = "new_group".localized
    }
    
    private func setTableView(){
        tableView.register(SelectContactTableViewCell.nib(), forCellReuseIdentifier: SelectContactTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
       
    }
    
    private func setCollectionView(){
        collectionView.register(SelectedContactCollectionViewCell.nib(), forCellWithReuseIdentifier: SelectedContactCollectionViewCell.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
       
    }
}

extension NewGroupViewController: UITableViewDelegate, UITableViewDataSource {
   
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectContactTableViewCell.cellIdentifier, for: indexPath) as! SelectContactTableViewCell
       // cell.notification = notifications[indexPath.row]
        return cell
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
}

extension NewGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: SelectedContactCollectionViewCell.cellIdentifier, for: indexPath) as! SelectedContactCollectionViewCell
       // let member = self.whiteboardMembers[indexPath.row]
        
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(member)
//        let image = UIImage.set_image(named: "icon_meeting_default_avatar")
//        cell.headImage.sd_setImage(with: URL(string: info.avatarUrlString ?? ""), placeholderImage: image, options: [], progress: nil, completed: nil)
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//       {
//          return CGSize(width: 80.0, height: 110.0)
//       }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
//    }
//
//    //    MARK: - 行最小间距
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 15
//    }
//
//    //    MARK: - 列最小间距
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 15
//    }
}


