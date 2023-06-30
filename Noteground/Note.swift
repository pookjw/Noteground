//
//  Note.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import Foundation
import SwiftData

@Model
final class Note {
    @Attribute([.unique], originalName: nil, hashModifier: nil) let id: UUID
    @Attribute([.encrypt], originalName: nil, hashModifier: nil) var note: String
    @Attribute var order: Int
    @Attribute var modifiedDate: Date
    
    // TODO: Replace with imageData and migrate it
    @Attribute([.externalStorage], originalName: nil, hashModifier: nil) var imageData: Data?
    
    init(id: UUID, note: String, order: Int, modifiedDate: Date, imageData: Data?) {
        self.id = id
        self.note = note
        self.order = order
        self.modifiedDate = modifiedDate
        self.imageData = imageData
    }
}
