//
//  XCGLoggerManager.swift
//  YippiCore
//
//  Created by Kit Foong on 24/09/2024.
//  Copyright © 2024 Chew. All rights reserved.
//

import UIKit
import XCGLogger
import Foundation
import CoreLocation

struct LogRequestModel {
    var date : String
    var urls: [URL]
}

var commonLog: XCGLogger?
var errorLog: XCGLogger?

func setupUncaughtExceptionHandler() {
    NSSetUncaughtExceptionHandler { exception in
        errorLog?.error("Uncaught exception: \(exception)")
        errorLog?.error("Call Stack Symbols: \(exception.callStackSymbols)")
    }
}

func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
    errorLog?.error("Fatal error: \(message()) in \(file):\(line)")
    Swift.fatalError(message(), file: file, line: line)
}

class XCGLoggerManager: NSObject {
    static let shared = XCGLoggerManager()
    
    func setupXCGLogger() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: Date())
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let ansiColorLogFormatter: ANSIColorLogFormatter = ANSIColorLogFormatter()
        ansiColorLogFormatter.colorize(level: .verbose, with: .colorIndex(number: 244), options: [.faint])
        ansiColorLogFormatter.colorize(level: .debug, with: .black)
        ansiColorLogFormatter.colorize(level: .info, with: .blue, options: [.underline])
        ansiColorLogFormatter.colorize(level: .warning, with: .red, options: [.faint])
        ansiColorLogFormatter.colorize(level: .error, with: .red, options: [.bold])
        ansiColorLogFormatter.colorize(level: .severe, with: .white, on: .red)
        
        if let fileUrl = documentsUrl?.appendingPathComponent("/NIMSDK/Logs/rw-\(dateString).log") {
            commonLog = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
            let fileDestination = FileDestination(writeToFile: fileUrl, identifier: "advancedLogger.fileDestination", shouldAppend: true)
            fileDestination.formatters = [ansiColorLogFormatter]
            commonLog?.add(destination: fileDestination)
        }
        
        if let errorFileUrl = documentsUrl?.appendingPathComponent("/NIMSDK/Logs/rwerror-\(dateString).log") {
            errorLog = XCGLogger(identifier: "advancedErrorLogger", includeDefaultDestinations: false)
            let errorFileDestination = FileDestination(writeToFile: errorFileUrl, identifier: "advancedLogger.fileDestination", shouldAppend: true)
            errorFileDestination.formatters = [ansiColorLogFormatter]
            errorLog?.add(destination: errorFileDestination)
        }
    }
    
    func getLogDirectory(name: String) -> String {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        var path: String = ""
        
        if let fileUrl = documentsUrl?.appendingPathComponent("/NIMSDK/Logs/\(name)") {
            path = fileUrl.path
        }
        return path
    }
    
    func saveWeeklyLog() {
        if let fileUrl = URL(string: getLogDirectory(name: "")) {
            let fileURLs = FileControlManager.shared.getFilesFromPath(fileUrl)
            var logArr: [URL] = []
            
            logArr.removeAll()
            logArr = fileURLs.filter({ $0.path.contains("rw-") })
            
            let filesWithinLastTwoWeek = filterFilesByDate(logArr, withinLastDays: 15)
            let differentFiles = logArr.difference(from: filesWithinLastTwoWeek)
            for file in differentFiles {
                FileControlManager.shared.deleteFile(atPath: file.path)
            }
        }
    }
    
    private func filterFilesByDate(_ files: [URL], withinLastDays days: TimeInterval) -> [URL] {
        let currentDate = Date()
        let dateThreshold = currentDate.addingTimeInterval(-days * 24 * 60 * 60)
        let filteredFiles = files.filter { fileURL in
            do {
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let modificationDate = fileAttributes[FileAttributeKey.creationDate] as? Date {
                    return modificationDate > dateThreshold
                }
            } catch {
                printIfDebug("Error retrieving attributes for file \(fileURL.path): \(error)")
            }
            return false
        }
        return filteredFiles
    }
    
    func clearAllZipFiles(needClearLog: Bool = false) {
        if let fileUrl = URL(string: self.getLogDirectory(name: "")) {
            let allFiles = FileControlManager.shared.getFilesFromPath(fileUrl)
            var zipFiles : [URL] = []
            if needClearLog {
                zipFiles = allFiles.filter { $0.path.contains("rw-") && $0.pathExtension.elementsEqual("log") }
            }
            zipFiles.append(contentsOf: allFiles.filter { $0.path.contains("rw-") && $0.pathExtension.elementsEqual("zip") })
            
            for zipFile in zipFiles {
                FileControlManager.shared.deleteFile(atPath: zipFile.path)
            }
        }
    }
    
    private func getLogFilesByType(_ model: LogRequestRLModel) -> [LogRequestModel]? {
        var fileUrls : [LogRequestModel]? = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        if let fileUrl = URL(string: self.getLogDirectory(name: "")) {
            let allFiles = FileControlManager.shared.getFilesFromPath(fileUrl)
            let logFiles = allFiles.filter { $0.path.contains("rw-") && $0.pathExtension.elementsEqual("log") }
            
            if model.type == "all" {
                // all log
                fileUrls = self.validateLogDate(urls: logFiles, isAll: true)
            } else {
                // filter log by date
                fileUrls = self.validateLogDate(urls: logFiles, isAll: false, startDate: dateFormatter.date(from: model.startDate), endDate: dateFormatter.date(from: model.endDate))
            }
        }
        
        return fileUrls
    }
    
    private func validateLogDate(urls: [URL], isAll: Bool, startDate: Date? = nil, endDate: Date? = nil) -> [LogRequestModel] {
        var fileUrls : [LogRequestModel] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        for log in urls {
            // rw-2023-10-25_095237.log
            let fileName = log.lastPathComponent
            printIfDebug(fileName)
            
            if let dashIndex = fileName.firstIndex(of: "-"), let underStrokeIndex = fileName.lastIndex(of: "_") {
                let nextToDashIndex = fileName.index(after: dashIndex)
                let range = nextToDashIndex..<underStrokeIndex
                let fileDateString = String(fileName[range])
                printIfDebug(fileDateString)
                
                if isAll {
                    if fileUrls.contains(where: { $0.date == fileDateString }), let row = fileUrls.firstIndex(where: {$0.date == fileDateString }) {
                        fileUrls[row].urls.append(log)
                    } else {
                        fileUrls.append(LogRequestModel(date: fileDateString, urls: [log]))
                    }
                } else {
                    if let fileDate = dateFormatter.date(from: fileDateString), let startDate = startDate, let endDate = endDate, let nextEndDate = Calendar.current.date(byAdding: .day, value: 1, to: endDate), fileDate.isBetween(startDate, and: nextEndDate) {
                        if fileUrls.contains(where: { $0.date == fileDateString }), let row = fileUrls.firstIndex(where: {$0.date == fileDateString }) {
                            fileUrls[row].urls.append(log)
                        } else {
                            fileUrls.append(LogRequestModel(date: fileDateString, urls: [log]))
                        }
                    }
                }
            } else {
                FileControlManager.shared.deleteFile(atPath: log.path)
            }
        }
        
        return fileUrls
    }
    
    func checkLogRequest(data: LogRequestRLModel, canDownload: Bool = false, completion: ((String, [URL], Bool) -> Void)? = nil) {
        guard let urls = self.getLogFilesByType(data), urls.isEmpty == false else {
            return
        }
       
        var allUrls : [URL] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: Date())
        let fileName = "rw_im_\(dateString).zip"
        
        for item in urls {
            allUrls.append(contentsOf: item.urls)
        }
        
        if allUrls.isEmpty == false {
            completion?(fileName, allUrls, canDownload)
        }
    }
    
    func logRequestInfo(_ content: String) {
        let group = DispatchGroup()
        group.enter()
        
        if let fileUrl = URL(string: self.getLogDirectory(name: "")) {
            let allFiles = FileControlManager.shared.getFilesFromPath(fileUrl)
            let zipFiles : [URL] = allFiles.filter { $0.path.contains("rw-") && $0.pathExtension.elementsEqual("log") }
            if zipFiles.isEmpty {
                setupXCGLogger()
            }
            group.leave()
        } else {
            group.leave()
        }
        
        group.notify(queue: .main) {
            commonLog?.info(content)
        }
    }
}

func printIfDebug(_ item: @autoclosure () -> Any, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    Swift.print(item(), separator: separator, terminator: terminator)
    #else
    XCGLoggerManager.shared.logRequestInfo("printIfDebug: \(item())")
    #endif
}
