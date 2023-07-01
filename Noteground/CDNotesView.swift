//
//  CDNotesView.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI
import SwiftData
import CoreData

struct CDNotesView: View {
    @Environment(\.managedObjectContext) private var context: NSManagedObjectContext
    @FetchRequest(entity: CDNote._entity, sortDescriptors: [], predicate: nil) private var results: FetchedResults<CDNote>
    
    var body: some View {
        List(results, id: \.self) { cdNote in
            Text(String(describing: cdNote))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let note: CDNote = .init(context: context)
                    note.uniqueID = .init()
                    note.body = .init()
                    note.modifiedDate = .init()
                    note.imageData = nil
                    
                    context.performAndWait {
                        context.insert(note)
                        try! context.save()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Core Data")
    }
}

#Preview {
    CDNotesView()
}
