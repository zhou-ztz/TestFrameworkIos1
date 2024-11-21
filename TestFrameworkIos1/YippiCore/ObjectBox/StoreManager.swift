//
//  StoreManager.swift
//  Yippi
//
//  Created by Francis Yeap on 29/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ObjectBox

//var store = StoreManager().store

class StoreManager {
    static let shared: StoreManager = StoreManager()
    
    var store: Store!
    
    init() {
        updateStoreValue()
    }
    
    static func createStore() throws -> Store {
        let databaseName = "yippi_store"
        let appSupport = try FileManager.default.url(for: .applicationSupportDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
            .appendingPathComponent(Bundle.main.bundleIdentifier!)
        let directory = appSupport.appendingPathComponent(databaseName)
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        
        return try Store(directoryPath: directory.path)
    }
    
    func updateStoreValue() {
        do {
            store = try? StoreManager.createStore()
        } catch {
            printIfDebug(error)
        }
    }
    
    func deleteAllFiles() {
        try? store.closeAndDeleteAllFiles()
        updateStoreValue()
    }
}
