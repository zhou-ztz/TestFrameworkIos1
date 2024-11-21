//
//  InputFileContainerCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/10.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class InputFileContainerCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var contentLab: UILabel!
    
    static let cellIdentifier = "InputFileContainerCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentLab.textColor = UIColor(red: 159, green: 159, blue: 159)
    }

    public func setFileData(data: [String : Any]){
        if let path = data["path"] as? String {
            titleLab.text = URL(fileURLWithPath: path).lastPathComponent
            icon.image = SendFileManager.setFileIcon(with:URL(fileURLWithPath: path).pathExtension)
        }
        if let size = data["fileSize"] as? String {
            contentLab.text = size
        }
       
        
        
    }
    
}
