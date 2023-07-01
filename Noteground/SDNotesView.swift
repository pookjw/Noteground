//
//  SDNotesView.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI
import SwiftData

struct SDNotesView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var notes: [Note]
    
    var body: some View {
        List(notes) { note in
            Text(String(describing: note))
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        let note: Note = .init(
                            uniqueID: .init(),
                            body: .init(),
                            modifiedDate: .init(),
                            imageData: nil
                        )
                        
                        modelContext.insert(note)
                        try! modelContext.transaction {
                            try modelContext.save()
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("SwiftData")
    }
}

#Preview {
    SDNotesView()
        .modelContainer(for: Note.self, inMemory: true, isAutosaveEnabled: false, isUndoEnabled: true) { result in
            switch result {
            case .failure(let failure):
                fatalError(String(describing: failure))
            default:
                break
            }
        }
}
