//
//  RootView.swift
//  Noteground
//
//  Created by Jinwoo Kim on 6/30/23.
//

import SwiftUI
import SwiftData
import CoreData

struct RootView: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @ObservedObject private var viewModel: RootViewModel = .init()
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Group {
                if let sdContext: ModelContext = viewModel.sdContext {
                    SDNotesView()
                        .modelContext(sdContext)
                } else {
                    ContentUnavailableView.search
                }
            }
            .background {
                ParentReader { parent in
                    guard let splitViewController = parent?.splitViewController else {
                        return
                    }
                    
                    splitViewController.maximumPrimaryColumnWidth = .infinity
                    splitViewController.preferredPrimaryColumnWidthFraction = 0.5
                    splitViewController.displayModeButtonVisibility = .never
                }
            }
        } detail: {
            if let cdContext: NSManagedObjectContext = viewModel.cdContext {
                CDNotesView()
                    .environment(\.managedObjectContext, cdContext)
            } else {
                ContentUnavailableView.search
            }
        }
        .task {
            try! await viewModel.load()
        }
    }
}

#Preview {
    RootView()
}
