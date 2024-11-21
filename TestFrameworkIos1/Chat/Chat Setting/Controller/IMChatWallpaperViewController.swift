//
//  IMChatWallpaperViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class IMChatWallpaperViewController: TSViewController {
    let dataArray = ["wallpaper_change".localized, "wallpaper_reset".localized]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.separatorStyle = .none
        //tableView.sectionFooterHeight = 0
        tableView.rowHeight = 50
        tableView.bounces = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SimpleTableItem")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setCloseButton(backImage: true, titleStr: "title_chat_wallpaper".localized)
        self.view.backgroundColor = AppTheme.inputContainerGrey
        self.view.addSubview(self.tableView)
    }
    
    func saveImage(newbackground: UIImage){
        let imageData = newbackground.jpegData(compressionQuality: 1)
        UserDefaults.standard.setValue(imageData, forKey: Constants.GlobalChatWallpaperImageKey)
        self.navigationController?.popViewController(animated: true)
    }
}

extension IMChatWallpaperViewController: UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableItem", for: indexPath)
        cell.textLabel!.text = dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 0) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            self.present(picker.fullScreenRepresentation, animated: true, completion: nil)
        }
        
        if (indexPath.row == 1) {
            
            let alert = UIAlertController(title: "wallpaper_reset".localized, message: "wallpaper_reset_confirm".localized, preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "ok".localized, style: .default) { (action) in
                UserDefaults.standard.removeObject(forKey: Constants.GlobalChatWallpaperImageKey)
                self.navigationController?.popViewController(animated: true)
            }
            let CancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (acion) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(yesButton)
            alert.addAction(CancelButton)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newbackground = info[.originalImage] as! UIImage
        let cellBackgroundView = UIImageView(image: newbackground)
        cellBackgroundView.frame = self.view.bounds
        self.saveImage(newbackground: newbackground)
        picker.dismiss(animated: true, completion: nil)
    }
}
