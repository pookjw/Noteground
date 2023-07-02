//
//  Note.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import Foundation
import SwiftData
import CoreData

final class NonisolatedValueStore<T: Sendable>: Sendable {
    var value: T?
    
    init(value: T?) {
        self.value = value
    }
}

@objc(_TtC10Noteground4Note)
actor Note: NSObject, PersistentModel, ModelActor {
    @objc static func entity() -> NSEntityDescription? {
        nil
    }
    nonisolated var executor: any ModelExecutor {
        defaultModelExecutor!
    }
    
    init(backingData: any BackingData<Note>) {
        super.init()
        self.backingData = backingData
    }
    
//    deinit {
//        backingDataPointer.deallocate()
//    }
    
//    private let backingDataPointer: UnsafeMutablePointer<DefaultBackingData<Note>> = .allocate(capacity: 1)
//    nonisolated var backingData: any BackingData<Note> {
//        get {
//            backingDataPointer.pointee
//        }
//        set {
//            backingDataPointer.pointee = newValue as! DefaultBackingData<Note>
//        }
//    }
    
    let _backingDataValueStore: NonisolatedValueStore<any BackingData<Note>> = .init(value: DefaultBackingData(for: Note.self))
    nonisolated var backingData: any BackingData<Note> {
        get {
            _backingDataValueStore.value!
        }
        set {
            _backingDataValueStore.value = newValue
        }
    }
    
    static func schemaMetadata() -> [(String, AnyKeyPath, Any?, Any?)] {
        [
            ("number", \Note._uniqueID, nil, Attribute([.unique])),
            ("body", \Note._body, nil, Attribute([.encrypt])),
            ("modifiedDate", \Note._modifiedDate, nil, nil),
            ("imageData", \Note._imageData, nil, Attribute([.externalStorage]))
        ]
    }
    
    private nonisolated var _uniqueID: UUID {
        get {
            backingData.getValue(for: \._uniqueID)
        }
        set {
            backingData.setValue(for: \._uniqueID, to: newValue)
        }
    }
    var uniqueID: UUID {
        get {
            _uniqueID
        }
        set {
            _uniqueID = newValue
        }
    }
    
    private nonisolated var _body: String {
        get {
            backingData.getValue(for: \._body)
        }
        set {
            backingData.setValue(for: \._body, to: newValue)
        }
    }
    var body: String {
        get {
            _body
        }
        set {
            _body = newValue
        }
    }

    private nonisolated var _modifiedDate: Date {
        get {
            backingData.getValue(for: \._modifiedDate)
        }
        set {
            backingData.setValue(for: \._modifiedDate, to: newValue)
        }
    }
    var modifiedDate: Date {
        get {
            _modifiedDate
        }
        set {
            _modifiedDate = newValue
        }
    }
    
    private nonisolated var _imageData: Data? {
        get {
            backingData.getValue(for: \._imageData)
        }
        set {
            backingData.setValue(for: \._imageData, to: newValue)
        }
    }
    var imageData: Data? {
        get {
            _imageData
        }
        set {
            _imageData = newValue
        }
    }
    
    init(uniqueID: UUID, body: String, modifiedDate: Date, imageData: Data?) {
        super.init()
        self._uniqueID = uniqueID
        self._body = body
        self._modifiedDate = modifiedDate
        self._imageData = imageData
    }
}

//@Model
//actor Notes: ModelActor {
//    nonisolated var executor: any ModelExecutor { defaultModelExecutor! }
//    
//    @Attribute([.unique], originalName: nil, hashModifier: nil) let uniqueID: UUID
//    @Attribute([.encrypt], originalName: nil, hashModifier: nil) var body: String
//    @Attribute var modifiedDate: Date
//    
//    // TODO: Replace with imageData and migrate it
//    @Attribute([.externalStorage], originalName: nil, hashModifier: nil) var imageData: Data?
//    
//    init(uniqueID: UUID, body: String, modifiedDate: Date, imageData: Data?) {
//        self.uniqueID = uniqueID
//        self.body = body
//        self.modifiedDate = modifiedDate
//        self.imageData = imageData
//    }
//}

@objc(cNote)
final class CDNote: NSManagedObject {
    override class func entity() -> NSEntityDescription {
        _entity
    }
    
    static let _managedObjectModel: NSManagedObjectModel = {
        let schema = Schema([Note.self])
        let managedObjectModel: NSManagedObjectModel = schema.makeManagedObjectModel()!
        let entity: NSEntityDescription = managedObjectModel.entities.first!
        entity.managedObjectClassName = NSStringFromClass(CDNote.self)
        
        return managedObjectModel
    }()
    
    static let _entity: NSEntityDescription = {
        let entity: NSEntityDescription = _managedObjectModel.entities.first!
        return entity
    }()
    
    @NSManaged var uniqueID: UUID
    @NSManaged var body: String
    @NSManaged var modifiedDate: Date
    @NSManaged var imageData: Data?
}
