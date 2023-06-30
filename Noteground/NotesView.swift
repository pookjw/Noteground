//
//  NotesView.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI
import SwiftData

struct NotesView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var notes: [Note]
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) { 
            List(notes) { note in
                
            }
        } content: { 
            
        } detail: { 
            
        }
    }
}

#Preview {
    NotesView()
        .modelContainer(for: Note.self, inMemory: true, isAutosaveEnabled: false, isUndoEnabled: true) { result in
            switch result {
            case .success(let _):
                break
            case .failure(let failure):
                fatalError(String(describing: failure))
            }
        }
}
