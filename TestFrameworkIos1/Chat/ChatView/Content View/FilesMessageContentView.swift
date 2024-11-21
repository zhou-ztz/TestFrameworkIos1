//
//  FilesMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 10/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel

class FilesMessageContentView: BaseContentView {
    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    
    lazy var fileImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ic_unknown")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var filenameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.semibold(FontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming
        
        let filenameSizeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 4
        }
        filenameSizeStackView.addArrangedSubview(filenameLabel)
        
        let imageNameStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        imageNameStackView.addArrangedSubview(fileImage)
        imageNameStackView.addArrangedSubview(filenameSizeStackView)
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
        }
        wholeStackView.addArrangedSubview(imageNameStackView)
        wholeStackView.addArrangedSubview(timeTickStackView)
        
        fileImage.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }

        imageNameStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(145)
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.top.equalTo(imageNameStackView.snp.bottom).offset(-10)
        }
        self.addSubview(wholeStackView)
        wholeStackView.snp.makeConstraints { make in
            make.width.equalTo(220)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 9:0)
            make.right.equalToSuperview().offset(showLeft ? -0:-9)
        }
    }
    
    private func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        
        let fileObject = message.messageObject as! NIMFileObject
        let fileType = URL(fileURLWithPath: fileObject.path ?? "").pathExtension
        
        fileImage.image = SendFileManager.fileIcon(with:fileType).icon
        
        self.filenameLabel.text = fileObject.displayName
        
        let size: Int64 = fileObject.fileLength / 1024
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.fileTapped(self.model)
    }
}

