//
//  CorrectionToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/7/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The toolbar for undo and redo.
public struct CorrectionToolbar: View {
    @EnvironmentObject private var observedWebView: ObservedWebView
    @EnvironmentObject private var selectionState: SelectionState
    @State private var hoverLabel: Text = Text(LocalizedStringKey("Correction"))
    
    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            ToolbarImageButton(
                systemName: "arrow.uturn.backward",
                action: { observedWebView.selectedWebView?.undo() },
                onHover: { over in hoverLabel = Text(over ? "Undo" : "Correction") }
            )
            ToolbarImageButton(
                systemName: "arrow.uturn.forward",
                action: { observedWebView.selectedWebView?.redo() },
                onHover: { over in hoverLabel = Text(over ? "Redo" : "Correction") }
            )
        }
    }
    
}

struct CorrectionToolbar_Previews: PreviewProvider {
    static var previews: some View {
        CorrectionToolbar()
    }
}
