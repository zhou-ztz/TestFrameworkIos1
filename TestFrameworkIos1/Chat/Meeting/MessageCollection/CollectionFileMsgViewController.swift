//
//  CollectionFileMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit



class CollectionFileMsgViewController: TSViewController {

    var favoriteModel: IMFileCollectionAttachment?
    var interactionController: UIDocumentInteractionController!
    var isDownLoading: Bool! = false
    
    lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var nameLable: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 17)
        lab.numberOfLines = 2
        return lab
    }()
    
    lazy var doneBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = AppTheme.secondaryColor
        btn.layer.cornerRadius = 7
        btn.setTitleColor(AppTheme.twilightBlue, for: .normal)
        btn.setTitle("viewholder_download_document".localized, for: .normal)
        btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var progress: UIProgressView = {
        let prog = UIProgressView()
        
        return prog
    }()
    
    init(model: IMFileCollectionAttachment) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(158)
            make.width.equalTo(168)
            make.height.equalTo(104)
        }
        
        self.view.addSubview(nameLable)
        nameLable.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp_bottomMargin).offset(14)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
        
        self.view.addSubview(progress)
        progress.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLable.snp_bottomMargin).offset(30)
            make.width.equalTo(194)
            make.height.equalTo(2)
        }
        
        self.view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(progress.snp_bottomMargin).offset(40)
            make.width.equalTo(202)
            make.height.equalTo(45)
        }
        

        self.title = favoriteModel?.name ?? ""
        self.nameLable.text  = favoriteModel?.name ?? ""
        self.imageView.image = SendFileManager.setFileIcon(with: favoriteModel?.ext ?? "docx")
        self.imageView.contentMode = .scaleAspectFit
        self.progress.isHidden = true
        doneBtn.backgroundColor = AppTheme.secondaryColor
        doneBtn.layer.cornerRadius = 7
        doneBtn.setTitleColor(AppTheme.twilightBlue, for: .normal)
        doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
    }
    
    @objc func doneAction(){
        
        if let url = URL(string: favoriteModel?.url ?? ""), let urlData = NSData(contentsOf: url) {
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let name = favoriteModel?.name ?? ""
            let dri = "\(documentsPath)/collectionFile/"
            if !FileManager.default.fileExists(atPath: dri) {
                try? FileManager.default.createDirectory(atPath: dri, withIntermediateDirectories: true, attributes: nil)
            }
            let path = documentsPath + "/collectionFile/" + name
            
            if !FileManager.default.fileExists(atPath: path) {
                
                progress.isHidden = true
                progress.progress = 0
                doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
                isDownLoading = false
                urlData.write(toFile: path, atomically: true)
             
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                    self?.isDownLoading = true
                    
                    self?.progress.progress = 1
                    self?.progress.isHidden = true
                    self?.doneBtn.setTitle("open".localized, for: .normal)
                }
            }else {
                self.openWithDocumentInterator(path: path)
            }
            
        }
        
        
    }
    
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(path: String){
        let url = URL(fileURLWithPath: path)
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = self.favoriteModel?.name ?? ""
        self.interactionController.presentPreview(animated: true)
    }
    

    //MARK: 文件下载
    func downLoadFile()
    {
       
    }

}


extension CollectionFileMsgViewController: UIDocumentInteractionControllerDelegate{
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }

}
