//
//  Note.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import Foundation
import SwiftData
import CoreData

@Model
final class Note {
    @Attribute([.unique], originalName: nil, hashModifier: nil) let uniqueID: UUID
    @Attribute([.encrypt], originalName: nil, hashModifier: nil) var body: String
    @Attribute var modifiedDate: Date
    
    // TODO: Replace with imageData and migrate it
    @Attribute([.externalStorage], originalName: nil, hashModifier: nil) var imageData: Data?
    
    init(uniqueID: UUID, body: String, modifiedDate: Date, imageData: Data?) {
        self.uniqueID = uniqueID
        self.body = body
        self.modifiedDate = modifiedDate
        self.imageData = imageData
    }
}

@objc(Note)
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
