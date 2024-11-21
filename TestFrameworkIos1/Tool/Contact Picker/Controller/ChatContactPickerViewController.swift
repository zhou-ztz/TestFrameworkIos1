//
//  ChatContactPickerViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class ChatContactPickerViewController: TSViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newContactLabel: UILabel!
    @IBOutlet weak var newGroupView: UIView!
    @IBOutlet weak var newContactView: UIView!
    @IBOutlet weak var newGroupLabel: UILabel!
    
    var screenHeight = UIScreen.main.bounds.height
    var scrollViewContentHeight = 1200 as CGFloat
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }
    
    private func setupView() {
        self.title = "new_chat_title".localized
        
        scrollView.contentSize = CGSizeMake(view.frame.size.width, scrollViewContentHeight)
        scrollView.delegate = self
        scrollView.bounces = false
        
        newContactLabel.textColor = .black
        newContactLabel.text = "rw_text_add_contact".localized
        newGroupLabel.textColor = .black
        newGroupLabel.text = "new_group".localized
        
        newContactView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleContactTap)))
        newGroupView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGroupTap)))

        setTableView()
    }
    
    private func setTableView(){
        tableView.register(ContactTableViewCell.nib(), forCellReuseIdentifier: ContactTableViewCell.cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.isScrollEnabled = false
    }
    
    @objc func handleContactTap() {
        //let newGroupVC = NewContactViee()
      //  let nav = UINavigationController(rootViewController: newGroupVV)
      //  self.present(nav, animated: true, completion: nil)
    }
    
    @objc func handleGroupTap() {
        let newGroupVC = NewGroupViewController()
        let nav = UINavigationController(rootViewController: newGroupVC)
        self.present(nav, animated: true, completion: nil)
    }
  
}

extension ChatContactPickerViewController: UITableViewDelegate, UITableViewDataSource {
   
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.cellIdentifier, for: indexPath) as! ContactTableViewCell
      
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

extension ChatContactPickerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y

        if scrollView == self.scrollView {
            if yOffset >= scrollViewContentHeight - screenHeight {
                scrollView.isScrollEnabled = false
                tableView.isScrollEnabled = true
            }
        }

        if scrollView == self.tableView {
            if yOffset <= 0 {
                self.scrollView.isScrollEnabled = true
                self.tableView.isScrollEnabled = false
            }
        }
    }
}
