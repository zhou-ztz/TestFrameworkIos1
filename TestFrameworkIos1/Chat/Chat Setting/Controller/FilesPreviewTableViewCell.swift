//
//  FilesPreviewTableViewCell.swift
//  Yippi
//
//  Created by Tinnolab on 10/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class FilesPreviewTableViewCell: UITableViewCell, BaseCellProtocol {
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.fileNameLabel.font = UIFont.systemFont(ofSize: 15)
        self.fileNameLabel.textColor = UIColor.black
        
        self.fileSizeLabel.font = UIFont.systemFont(ofSize: 11)
        self.fileSizeLabel.textColor = UIColor.lightGray
    }
    
    func UISetup(fileObject: NIMFileObject) {
        
        self.fileImageView.image = SendFileManager.fileIcon(with:URL(fileURLWithPath: fileObject.path ?? "").pathExtension).icon

        self.fileNameLabel.text = fileObject.displayName
        
        let size: Int64 = (fileObject.fileLength) / 1024
        self.fileSizeLabel.text = String(format: "%lldKB", size)
    }
    
}
