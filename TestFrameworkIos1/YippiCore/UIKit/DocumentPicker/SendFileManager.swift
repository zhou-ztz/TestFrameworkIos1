//
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit
    
@objcMembers
public class SendFileManager: NSObject, UIDocumentPickerDelegate {
    
    public static let instance = SendFileManager()
    
    private var types: [String] = [(kUTTypeContent as String), (kUTTypeItem as String)]
    public var completion: (([URL]) -> Void)?
    
    @objc public func presentView(owner: UIViewController) {
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
//        picker.view.tintColor = AppTheme.primaryColor
//        UIBarButtonItem.appearance().tintColor = AppTheme.primaryColor
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key.foregroundColor: AppTheme.primaryColor], for: UIControl.State.normal)

        owner.present(picker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        defer { controller.dismiss(animated: true, completion: nil) }
        
        let newUrls = urls.compactMap { url -> URL? in
            let docPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
            let filePath = docPath + "/chatFile/" + url.lastPathComponent
            do {
                if FileManager.default.fileExists(atPath: filePath) {
                    try FileManager.default.removeItem(atPath: filePath)
                }else{
                    let filesArray = try FileManager.default.contentsOfDirectory(atPath: docPath + "/chatFile/" ) as [String]
                    if filesArray.count >= 5 {
                        
                        let path = self.sortFileWithDate(filesArray: filesArray)
                        try FileManager.default.removeItem(atPath: path)
                    }
                }
                
                let data = try Data(contentsOf: url)
                
                FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                return URL(fileURLWithPath: filePath)
            } catch {
                return nil
            }
        }
        completion?(newUrls)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        defer { controller.dismiss(animated: true, completion: nil) }
    }
    
    @objc public static func setFileIcon(with fileExtension: String) -> UIImage {
        
        let items = ["png", "gif", "jpg", "jpeg", "xls", "xlsx", "ppt", "pptx", "html", "htm", "zip", "7z", "mp4", "mp3", "doc", "docx", "pdf", "txt", "rar"]
        let item = items.firstIndex(of: fileExtension.lowercased()) ?? NSNotFound
        
        switch item {
        case 0:
            return UIImage.set_image(named: "ic_png")!
        case 1:
            return UIImage.set_image(named: "ic_gif")!
        case 2:
            return UIImage.set_image(named: "ic_jpg")!
        case 3:
            return UIImage.set_image(named: "ic_jpeg")!
        case 4:
            return UIImage.set_image(named: "ic_xls")!
        case 5:
            return UIImage.set_image(named: "ic_xlsx")!
        case 6:
            return UIImage.set_image(named: "ic_ppt")!
        case 7:
            return UIImage.set_image(named: "ic_pptx")!
        case 8:
            return UIImage.set_image(named: "ic_html")!
        case 9:
            return UIImage.set_image(named: "ic_htm")!
        case 10:
            return UIImage.set_image(named: "ic_zip")!
        case 11:
            return UIImage.set_image(named: "ic_7z")!
        case 12:
            return UIImage.set_image(named: "ic_mp4")!
        case 13:
            return UIImage.set_image(named: "ic_mp3")!
        case 14:
            return UIImage.set_image(named: "ic_doc")!
        case 15:
            return UIImage.set_image(named: "ic_docx")!
        case 16:
            return UIImage.set_image(named: "ic_pdf")!
        case 17:
            return UIImage.set_image(named: "ic_txt")!
        case 18:
            return UIImage.set_image(named: "ic_rar")!
        default:
            return UIImage.set_image(named: "ic_unknown")!
        }
    }
    
    public static func fileIcon(with fileExtension: String) -> (icon: UIImage, type: String) {
        var image = UIImage.set_image(named: "ic_unknown")!
        var text = "msg_tips_file"
        
        let items = ["png", "gif", "jpg", "jpeg", "xls", "xlsx", "ppt", "pptx", "html", "htm", "zip", "7z", "mp4", "mp3", "doc", "docx", "pdf", "txt", "rar"]
        let item = items.firstIndex(of: fileExtension.lowercased()) ?? NSNotFound
        switch item {
            case 0, 1, 2, 3:
                image = UIImage.set_image(named: "ic_image")!
                text = "Image"
            case 4, 5:
                image = UIImage.set_image(named: "ic_xlsx")!
                text = "Xlsx"
            case 6, 7:
                image = UIImage.set_image(named: "ic_ppt")!
                text = "Ppt"
            case 8, 9:
                image = UIImage.set_image(named: "ic_html")!
                text = "Html"
            case 10, 11:
                image = UIImage.set_image(named: "ic_zip")!
                text = "Zip"
            case 12, 13:
                image = UIImage.set_image(named: "ic_media")!
                text = "Media"
            case 14:
                image = UIImage.set_image(named: "ic_doc")!
                text = "Doc"
            case 15:
                image = UIImage.set_image(named: "ic_docx")!
                text = "Docx"
            case 16:
                image = UIImage.set_image(named: "ic_pdf")!
                text = "Pdf"
            case 17:
                image = UIImage.set_image(named: "ic_txt")!
                text = "Txt"
            case 18:
                image = UIImage.set_image(named: "ic_rar")!
                text = "Rar"
            default:
                image = UIImage.set_image(named: "ic_unknown")!
                text = "msg_tips_file"
        }
        return (icon: image, type: text)
    }
    //根据日期排序
    func sortFileWithDate(filesArray: [String]) -> String{

        var dataArray = [[String: Any]]()
        let documentsPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        for file in filesArray {
            let filePath = documentsPath + "/chatFile/" + file
            let properties = try! FileManager.default.attributesOfItem(atPath: filePath) as [FileAttributeKey : Any]
            let modDate = properties[FileAttributeKey.creationDate]
            
            let dict = ["path": filePath, "date": modDate!] as [String : Any]
            dataArray.append(dict)

        }
        
        // sort by creation date
        dataArray.sort { (s1, s2) -> Bool in
            let date1 = s1["date"] as? Date
            let date2 = s2["date"] as? Date
            if date1?.compare(date2!) == .orderedAscending
            {
                return false
            }
            
            if date1?.compare(date2!) == .orderedDescending
            {
                return true
            }

            return true

        }
       
        let dict = dataArray.last!
        if let path = dict["path"] {
            return path as! String
        }
        
        return ""
    }
    
    
    @objc public func covertToFileString(path: String) -> Bool {
        let properties = try! FileManager.default.attributesOfItem(atPath: path)
        let fileSize = properties[FileAttributeKey.size] as! UInt64
        let convertedValue: Double = Double(fileSize)
        // 大于100M
        if convertedValue > 1024 * 1024 * 100 {
            return true
        }
        return false
    }
}
