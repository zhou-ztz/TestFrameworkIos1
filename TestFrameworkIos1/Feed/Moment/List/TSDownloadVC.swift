//
//  TSDownloadVC.swift
//  ThinkSNSPlus
//
//  Created by SmellTime on 2018/11/7.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import Alamofire
import Photos

class TSDownloadVC: TSViewController {
    var downloadUrl: String!
    var cancelBlcok: (() -> Void)?
    var showNav: UINavigationController!

    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var bearView: UIView!
    @IBOutlet weak var downloadLabel: UILabel!
    @IBOutlet weak var coverLabel: UILabel!
    /// 相当于下载按钮到左侧的距离
    @IBOutlet weak var coverViewLC: NSLayoutConstraint!
    //指定下载路径
    let destination: DownloadRequest.DownloadFileDestination = { _, response in
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentURL.appendingPathComponent(response.suggestedFilename!)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    var downloadRequest: DownloadRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        bearView.layer.cornerRadius = 10
        bearView.clipsToBounds = true

        downloadView.backgroundColor = TSColor.main.theme
        downloadView.layer.cornerRadius = 13
        downloadLabel.textColor = .white

        coverView.backgroundColor = TSColor.main.theme.withAlphaComponent(0.2)
        coverView.layer.cornerRadius = 13
        coverView.clipsToBounds = true
        coverLabel.textColor = TSColor.main.theme
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadDidTap))
        downloadView.addGestureRecognizer(reloadTap)
        /// 判断相册权限
    }

    @IBAction func cancelBtnClick(_ sender: Any) {
        if let downloadRequest = downloadRequest {
            downloadRequest.cancel()
        }
        dismiss()
    }
    // MARK: - 移除视图
    func dismiss() {
        removeFromParent()
        view.removeFromSuperview()
        showNav.removeFromParent()
        showNav.view.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - 下载
    /// 开始下载
    func beginDownload() {
        guard !downloadUrl.isEmpty else { return }
        downloadRequest = Alamofire.download(downloadUrl, to: destination)
        downloadRequest?.downloadProgress(closure: downloadProgress)
        downloadRequest?.responseData(completionHandler: downloadResponse)
    }
    /// 重新下载
    @objc func reloadDidTap() {
        downloadView.backgroundColor = TSColor.main.theme
        coverView.backgroundColor = UIColor(hex: 0xDEF0F7)
        downloadLabel.text = "---"
        coverLabel.text = "---"
        downloadLabel.textColor = .white
        coverLabel.textColor = TSColor.main.theme
        beginDownload()
    }
    /// 下载响应
    func downloadResponse(response: DownloadResponse<Data>) {
        switch response.result {
        case .success(_):
            //下载完成
            downloadLabel.text = "downlaod_complete".localized
            cancelBtn.setTitle("video_downlaod_complete".localized, for: .normal)
            self.saveVideoToAla(videoURL: response.destinationURL!)
            downloadRequest = nil
        case .failure(error:):
            downloadLabel.text = "downlaod_retry".localized
            downloadView.backgroundColor = .red
            coverLabel.text = "downlaod_retry".localized
            coverLabel.textColor = .white
            coverView.backgroundColor = .red
            break
        }
    }
    /// 下载进度
    func downloadProgress(progress: Progress) {
        let proStr = String(format: "text_download".localized + "%d%", Int(progress.fractionCompleted * 100)) + "%"
        coverViewLC.constant = CGFloat(164 * progress.fractionCompleted)
        self.updateViewConstraints()
        downloadLabel.text = proStr
        coverLabel.text = proStr
    }
    // MARK: - 保存到相册
    func saveVideoToAla(videoURL: URL) {
        PHPhotoLibrary.shared().performChanges({
            _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)?.placeholderForCreatedAsset
        }, completionHandler: { (status, aError) in
            if status {
                try! FileManager.default.removeItem(at: videoURL)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.dismiss()
                })
            } else {
                assert(false, "aError?.localizedDescription")
            }
        })
    }
}
