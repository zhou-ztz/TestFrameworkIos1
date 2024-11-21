//
//  TSDownloadNetworkManager.swift
//  ThinkSNS +
//
//  Created by 小唐 on 20/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  下载管理器

import Foundation

import SDWebImage

class TSDownloadNetworkNanger {

    static let share = TSDownloadNetworkNanger()
    private init() {
    }
    
    func getFinalUrl(for url: String, completion: ((_ url: String) -> Void)? = nil) {
        
        guard let url = URL(string: url) else {
            completion?("")
            return
        }
        
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: Constants.timeout)
        
        request.httpMethod = "HEAD"
        URLSession.shared
            .dataTask(with: request) { (data, response, error) in
                guard let urlResponse: URLResponse? = response else {
                    completion?("")
                    return
                }
                completion?((urlResponse?.url?.absoluteString).orEmpty)
            }.resume()
    }

    /// 根据图片文件id获取图片链接
    func imageUrlStringWithImageFileId(_ fileId: Int) -> String {
        let strPrefixUrl = TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue
        let strUrl = String(format: "%@/%d", strPrefixUrl, fileId)
        return strUrl
    }

    /// 下载单张图片
    /// Note：下载失败没做任何处理
    func downloadImage(with imageUrl: String, complete: (() -> Void)? ) -> Void {
        // 查看缓存中是否有图片
        let image = SDImageCache.shared.imageFromCache(forKey: imageUrl)
   
        if image == nil, let url: URL = URL(string: imageUrl) {
            // 请求图片
            SDWebImageDownloader.shared.downloadImage(
                with: url,
                options: .highPriority, progress: nil) { (img, _, _, _) in
                    guard let image = image else { return }
                    SDImageCache.shared.store(img, forKey: imageUrl, completion: nil)
                    complete?()
            }
            
        } else {
            // 有图片，则不需要请求
            complete?()
        }
    }
    /// 下载多张图片
    /// Note：下载失败没做任何处理
    func downloadImages(with urls: [String], complete: @escaping(() -> Void)) -> Void {
        // 1. url 去重
        let imageUrlList: [String] = Array<String>(Set(urls))
        let group = DispatchGroup()
        // 2. 查看缓存中是否有该key的图片，没有则去下载
        for imageUrl in imageUrlList {
            group.enter()
            self.downloadImage(with: imageUrl, complete: {
                group.leave()
            })
        }
        // 3. 全部下载完毕
        group.notify(queue: DispatchQueue.main) {
            complete()
        }
    }
}
