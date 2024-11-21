//
//  IMExportMessageViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/23.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD
import SSZipArchive
import NIMSDK

class IMExportMessageViewController: TSViewController {

    static let aesVectorString = "0123456789012345"
    
    var contentView: IMMigrateProgressView!
    var curAlertController: UIAlertController!
    var secureKey: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "backup_migrate_chat_export".localized
        contentView = IMMigrateProgressView(frame: self.view.bounds)
        contentView.stopButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        contentView.setTip(tip: "backup_migrate_chat_export_msg".localized)
        self.view.addSubview(self.contentView)
        self.exportMessageInfos()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.contentView.frame = self.view.bounds
    }
  
    @objc func onCancelButton(){
        
    }

    func exportMessageInfos(){
     
        NIMSDK.shared().conversationManager.exportMeessageInfos(with: self) { [weak self] (progress) in
            self?.contentView.setProgress(progress: CGFloat(progress))
        } completion: { (error, resultFilePath) in
            if let error = error {
                self.onExportFailed(error: error)
                return
            }
            if let filePath = resultFilePath {
                self.onExportSuccessAtPath(infoFilePath: filePath)
            }
        }
    }
    
    func onExportSuccessAtPath(infoFilePath: String) {
        SVProgressHUD.show()
        // 对导出结果进行压缩，可以有效减少文件尺寸
        let zipFilePath = self.zipMessageFileAtPath(infoFilePath: infoFilePath)
        if zipFilePath.count == 0 {
            SVProgressHUD.dismiss()
            return
        }
        
        // 对导出结果进行加密，避免明文消息的泄露
        DispatchQueue.global().async {
            let encryptedFilePath = self.encryptMessageDataAtPath(path: zipFilePath)
            DispatchQueue.main.async {
                //[self uploadMessageFileToServer:encryptedFilePath];
            }
            
        }
    }
    
    
    func onExportFailed(error: Error) {
        self.curAlertController = UIAlertController(title: "backup_migrate_chat_failed_export".localized, message: "backup_migrate_chat_failed_format_export".localized, preferredStyle: .alert)
          
        // 返回
        let actionBack = UIAlertAction(title: "cancel".localized, style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        self.curAlertController.addAction(actionBack)
        let actionRetry = UIAlertAction(title: "backup_migrate_chat_retry_export".localized, style: .default) { [weak self] (action) in
            self?.curAlertController.dismiss(animated: true, completion: nil)
            self?.exportMessageInfos()
        }
        self.curAlertController.addAction(actionRetry)
        self.present(self.curAlertController, animated: true, completion: nil)

    }
    
    
    
    //MARK: -- 压缩
    func zipMessageFileAtPath(infoFilePath: String) ->String {
        let filePath: NSString = NSString(string: infoFilePath)
        let fileName = filePath.lastPathComponent
        var zipPath = filePath.deletingPathExtension
        zipPath = zipPath + "zip"
        print("zipPath  = \(zipPath)")
        print("infoFilePath  = \(infoFilePath)")
        let zipper = SSZipArchive(path: zipPath)
        let _ = zipper.open
        zipper.writeFile(atPath: infoFilePath, withFileName: fileName, withPassword: nil)
        let _ = zipper.close
        // 删除中间文件
        DispatchQueue.main.async {
            do {
                try  FileManager.default.removeItem(atPath: infoFilePath)
            } catch {
                
            }
        }
        return zipPath
    }

//    MARK: -- 加密
    func encryptMessageDataAtPath(path: String) -> String {
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        let aesKey = "".randomStringWithLength(length: 32)
        let data1 = NSData(data: data!) as NSData
        self.secureKey = aesKey
        let encryptedData = data1.aes256Encrypt(withKey: data!, iv: data)
        
//        let *aesKey = [NSString randomStringWithLength:32];
//        self.secureKey = aesKey;
//        NSData *encryptedData = [data aes256EncryptWithKey:aesKey vector:aesVectorString];
//        NSString *encrypedPath = [path stringByAppendingString:@"aes256"];
//        [encryptedData writeToFile:encrypedPath atomically:YES];
//
//        // 移除中间文件
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//        });

        return ""
    }

      //MARK: -- upload to server
    func uploadMessageFileToServer(path: String) {
        NIMSDK.shared().resourceManager.upload(path, progress: nil) { (urlString, error) in
            DispatchQueue.main.async {
                do {
                    try  FileManager.default.removeItem(atPath: path)
                } catch {
                    
                }
            }
            if let error = error {
                //[self onMigrateToRemoteFailed:error];
                return
            }
            guard let url = urlString else {return}
            self.updateMigrateMessageInfoWithURL(url: url)
        }
     
    }

    func updateMigrateMessageInfoWithURL(url: String) {
        NIMSDK.shared().conversationManager.updateMigrateMessageInfo(withURL: url, key: self.secureKey) { [weak self] (error) in
            SVProgressHUD.dismiss()
            if let error = error {
                //[self onMigrateToRemoteFailed:error];
            }else{
               // [self onMigrateToRemoteSuccess];
            }
            
        }
     
    }

}

extension IMExportMessageViewController: NIMExportMessageDelegate {
    
}



