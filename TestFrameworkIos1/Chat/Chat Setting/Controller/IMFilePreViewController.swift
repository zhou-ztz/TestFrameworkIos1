//
//  IMFilePreViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/23.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMFilePreViewController: TSViewController {

    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progress: UIProgressView!
    
    var fileObject: NIMFileObject!
    var interactionController: UIDocumentInteractionController!
    var isDownLoading: Bool! = false
    
    // By Kit Foong (Refresh table function)
    var refreshTable: (() -> Void)?
    
    init(object: NIMFileObject) {
        super.init(nibName: nil, bundle: nil)
        fileObject = object
        NIMSDK.shared().chatManager.add(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let msg = self.fileObject.message {
            NIMSDK.shared().chatManager.cancelFetchingMessageAttachment(msg)
        }
        NIMSDK.shared().chatManager.remove(self)
    }
    
    func setupNav() {
        var backButton = UIBarButtonItem(image: UIImage.set_image(named: "topbar_back"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem  = backButton
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true, completion: {
            if let refreshTable = self.refreshTable {
                refreshTable()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = fileObject.displayName
        self.nameLable.text  = fileObject.displayName
        if let path = fileObject.path{
            self.imageView.image = SendFileManager.setFileIcon(with: URL(fileURLWithPath: path).pathExtension)
        }
        self.imageView.contentMode = .scaleAspectFit
        self.progress.isHidden = true 
        doneBtn.backgroundColor = AppTheme.secondaryColor
        doneBtn.layer.cornerRadius = 7
        doneBtn.setTitleColor(AppTheme.twilightBlue, for: .normal)
        
        self.setupNav()
        
        // By Kit Foong (Check file is it exist to update button design)
        let urlPath = self.fileObject.path ?? ""
        
        if FileManager.default.fileExists(atPath: urlPath) {
            doneBtn.setTitle("open".localized, for: .normal)
        } else {
            doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
    }

    @IBAction func doneAction(_ sender: UIButton) {
        guard let filePath = self.fileObject.path else {return}
        
        if FileManager.default.fileExists(atPath: filePath) {
            self.openWithDocumentInterator()
        }else{
            if isDownLoading {
                if let msg = self.fileObject.message {
                    NIMSDK.shared().chatManager.cancelFetchingMessageAttachment(msg)
                }
                progress.isHidden = true
                progress.progress = 0
                doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
                isDownLoading = false
                
            }else{
                self.downLoadFile()
            }
        }
        
      
        
        
    }
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(){
        let url = URL(fileURLWithPath: self.fileObject.path ?? "")
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = self.fileObject.displayName ?? ""
        self.interactionController.presentPreview(animated: true)
    }
    
    //MARK: 文件下载
    func downLoadFile()
    {
        if let msg = self.fileObject.message {
            do {
                try NIMSDK.shared().chatManager.fetchMessageAttachment(msg)
            } catch {
                print("error = \(error.localizedDescription)")
            }
         
        }
    }


}

extension IMFilePreViewController: NIMChatManagerDelegate {
    
    func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
        if message.messageId == self.fileObject.message?.messageId {
            self.isDownLoading = true
            self.progress.isHidden = false
            self.progress.progress = progress
            doneBtn.setTitle("viewholder_download_cancel".localized, for: .normal)
        }
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        if message.messageId == self.fileObject.message?.messageId {
            self.isDownLoading = false
            self.progress.isHidden = true
            
            if let _ = error {
                self.progress.progress = 0
                doneBtn.setTitle("download_failed_try_again".localized, for: .normal)
            }else{
                doneBtn.setTitle("open".localized, for: .normal)
                self.openWithDocumentInterator()
            }
            
        }
       
    }
}

extension IMFilePreViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }

}
