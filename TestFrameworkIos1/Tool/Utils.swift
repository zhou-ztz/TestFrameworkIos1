import Foundation
import UIKit

class Utils {
    static func getStayEventTimerValue() -> Double {
        return 5
    }
    
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    //录制时的配置路径
    static func videoTaskDir() -> String {
        let path = (rootPath() as NSString).appendingPathComponent("task")
        try? deleteCache(path: path)
        return path
    }

    //录制视频的保存地址
    static func videoRecordCachePath() -> String {
        let path = ((videoCacheDir() as NSString).appendingPathComponent(fileName()) as NSString).appendingPathExtension("mp4")!
        try? deleteCache(path: path)
        return path
    }


    static func minivideoPreloadCachePath() -> String {
        let path = (videoCacheDir() as NSString).appendingPathComponent("default_video_file_dir")
        return path
    }
    
    static private func videoCacheDir() -> String {
        let path = (rootPath() as NSString).appendingPathComponent("com.yippiweb.cache")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == false {
            do {
                try fileManager.createDirectory(atPath: path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                // do nothing
            }
        }
        return path
    }

    //删除单个文件
    static func deleteCache(path: String) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                throw error
            }
        }
    }

    static private func rootPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    }

    static func fileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        return dateFormatter.string(from: Date())
    }
}
