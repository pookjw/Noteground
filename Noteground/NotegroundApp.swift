//
//  NotegroundApp.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI
import SwiftData

@main
struct NotegroundApp: App {

    var body: some Scene {
        WindowGroup {
            NotesView()
        }
        .modelContainer(for: Note.self, inMemory: true, isAutosaveEnabled: false, isUndoEnabled: true) { result in
            switch result {
            case .success(let _):
                break
            case .failure(let failure):
                fatalError(String(describing: failure))
            }
        }
    }
}
