//
//  RootViewModel.swift
//  Noteground
//
//  Created by Jinwoo Kim on 7/1/23.
//

import SwiftUI
import SwiftData
import CoreData

actor RootViewModel: ObservableObject {
    private var sdContainer: ModelContainer?
    private var cdContainer: NSPersistentContainer?
    
    private var sd_nsContext: NSManagedObjectContext?
    @MainActor @Published private(set) var sdContext: ModelContext?
    @MainActor @Published private(set) var cdContext: NSManagedObjectContext?
    
    private nonisolated var containerURL: URL {
        FileManager
            .default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.pookjw.notegorund")!
            .appending(path: "default", directoryHint: .notDirectory)
            .appendingPathExtension("sqlite")
    }
    
    private var cdRemoteChangeTask: Task<Void, Never>?
    private var sdDidSaveTask: Task<Void, Never>?
    private var cdDidSaveTask: Task<Void, Never>?
    
    deinit {
        cdRemoteChangeTask?.cancel()
        sdDidSaveTask?.cancel()
        cdDidSaveTask?.cancel()
    }
    
    func load() async throws {
        print(containerURL)
        try await loadSDProperties()
        try await loadCDProperties()
        await bindMergeObservers()
    }
    
    private func loadSDProperties() async throws {
        let modelConfiguration: ModelConfiguration = .init("Noteground", url: containerURL, readOnly: false, cloudKitContainerIdentifier: nil)
        let sdContainer: ModelContainer = try .init(for: Note.self, migrationPlan: nil, modelConfiguration)
        let sdContext: ModelContext = await sdContainer.mainContext
        let sd_nsContext: NSManagedObjectContext = await Mirror(reflecting: sdContext)
            .descendant("_nsContext") as! NSManagedObjectContext
        
        sd_nsContext.name = "SwiftData Context"
        sd_nsContext.transactionAuthor = "Noteground"
        
        self.sdContainer = sdContainer
        self.sd_nsContext = sd_nsContext
        await MainActor.run {
            self.sdContext = sdContext
        }
    }
    
    private func loadCDProperties() async throws {
        let cdContainer: NSPersistentContainer = .init(name: "Noteground", managedObjectModel: CDNote._managedObjectModel)
        
        let persistentStoreDescription: NSPersistentStoreDescription = .init(url: containerURL)
        cdContainer.persistentStoreDescriptions = [persistentStoreDescription]
        persistentStoreDescription.isReadOnly = false
        persistentStoreDescription.shouldAddStoreAsynchronously = true
        persistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        persistentStoreDescription.setOption(true as NSNumber, forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey")
        
        for persistentStoreDescription in cdContainer.persistentStoreDescriptions {
            let _: Void = try! await withCheckedThrowingContinuation { continuation in
                cdContainer.persistentStoreCoordinator.addPersistentStore(with: persistentStoreDescription) { _, error in
                    if let error: Error {
                        continuation.resume(with: .failure(error))
                    } else {
                        continuation.resume(with: .success(()))
                    }
                }
            }
        }
        
        self.cdContainer = cdContainer
        await MainActor.run {
            self.cdContext = cdContainer.viewContext
        }
    }
    
    private func bindMergeObservers() async {
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = cdContainer!.persistentStoreCoordinator
        let cdContext: NSManagedObjectContext = await MainActor.run { self.cdContext }!
        let sd_nsContext: NSManagedObjectContext = sd_nsContext!
        
        // SwiftData -> Core Data
        
        // iOS 17.0 beta 2 : not working?
//        sdDidSaveTask = .init {
//            for await notification in NotificationCenter.default.notifications(named: ModelContext.didSave, object: nil) {
//                print(notification)
//            }
//        }
        sdDidSaveTask = .init {
            for await notification in NotificationCenter.default.notifications(named: NSNotification.Name.NSManagedObjectContextDidSave, object: sd_nsContext) {
                cdContext.mergeChanges(fromContextDidSave: notification)
            }
        }
        
        // Works but unsafe
//        cdRemoteChangeTask = .init {
//            for await notification in NotificationCenter.default.notifications(named: NSNotification.Name.NSPersistentStoreRemoteChange, object: persistentStoreCoordinator) {
////                let historyToken: NSPersistentHistoryToken = notification.userInfo![NSPersistentHistoryTokenKey] as! NSPersistentHistoryToken
//                let historyToken: NSPersistentHistoryToken = cdContext.persistentStoreCoordinator!.currentPersistentHistoryToken(fromStores: nil)!
//                var dictionary: [String: Int] = historyToken.value(forKey: "_storeTokens") as! [String: Int]
//                let (key, value): (String, Int) = dictionary.first!
//                dictionary[key] = value - 1
//                historyToken.setValue(dictionary, forKey: "_storeTokens")
//                
//                let reqeust: NSPersistentHistoryChangeRequest = .fetchHistory(after: historyToken)
//                reqeust.resultType = .transactionsAndChanges
//                
//                let result: NSPersistentHistoryResult = try! await withCheckedThrowingContinuation { continuation in
//                    cdContext.performAndWait {
//                        do {
//                            let result: NSPersistentHistoryResult = try cdContext.execute(reqeust) as! NSPersistentHistoryResult
//                            continuation.resume(with: .success(result))
//                        } catch {
//                            continuation.resume(with: .failure(error))
//                        }
//                    }
//                }
//                
//                let transactions: [NSPersistentHistoryTransaction] = result.result as! [NSPersistentHistoryTransaction]
//                
//                for transaction in transactions {
//                    guard
//                        transaction.contextName == "SwiftData Context" &&
//                            transaction.author == "Noteground"
//                    else {
//                        continue
//                    }
//                    
//                    cdContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
//                }
//            }
//        }
        
        // Core Data -> SwiftData
        cdDidSaveTask = .init {
            for await notification in NotificationCenter.default.notifications(named: NSNotification.Name.NSManagedObjectContextDidSave, object: cdContext) {
                sd_nsContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
}
