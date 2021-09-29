//
//  TableToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/8/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// Enum to identify directions for adding rows and columns.
///
/// Case "before" means to the left, and "after" means to the right for columns.
/// Case "before" means above, and "after' means below for rows.
public enum TableDirection {
    case before
    case after
}

/// The toolbar used for creating and editing a table.
public struct TableToolbar: View {
    @EnvironmentObject var toolbarPreference: ToolbarPreference
    @EnvironmentObject private var observedWebView: ObservedWebView
    @EnvironmentObject private var selectionState: SelectionState
    @State private var showTableSizer: Bool = false
    @State private var tappedInTableSizer: Bool = false
    @State private var rows: Int = 0
    @State private var cols: Int = 0
    @State private var addHoverLabel: Text = Text("Add")
    @State private var deleteHoverLabel: Text = Text("Delete")
    
    public var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .bottom) {
                LabeledToolbar(label: Text("Create")) {
                    ToolbarImageButton(action: { showTableSizer.toggle() } ) {
                        CreateTable()
                    }
                    .disabled(selectionState.isInTable)
                    .popover(isPresented: $showTableSizer) {
                        TableSizer(rows: $rows, cols: $cols, showing: $showTableSizer, tapped: $tappedInTableSizer)
                            .onAppear() {
                                rows = 0
                                cols = 0
                            }
                            .onDisappear() {
                                if tappedInTableSizer && rows > 0 && cols > 0 {
                                    observedWebView.selectedWebView?.insertTable(rows: rows, cols: cols)
                                }
                            }
                    }
                }
                Divider()
                LabeledToolbar(label: addHoverLabel) {
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addHeader() },
                        onHover: { over in addHoverLabel = Text(over ? "Add Header" : "Add") }
                    ) {
                        AddHeader(rows: 2, cols: 3)
                    }
                    .disabled(!selectionState.isInTable || selectionState.header)
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addRow(.after) },
                        onHover: { over in addHoverLabel = Text(over ? "Add Row Below" : "Add") }
                    ) {
                        AddRow(direction: .after)
                    }
                    .disabled(!selectionState.isInTable)
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addRow(.before) },
                        onHover: { over in addHoverLabel = Text(over ? "Add Row Above" : "Add") }
                    ) {
                        AddRow(direction: .before)
                    }
                    .disabled(!selectionState.isInTable || selectionState.thead)
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addCol(.after) },
                        onHover: { over in addHoverLabel = Text(over ? "Add Column After" : "Add") }
                    ) {
                        AddCol(direction: .after)
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addCol(.before) },
                        onHover: { over in addHoverLabel = Text(over ? "Add Column Before" : "Add") }
                    ) {
                        AddCol(direction: .before)
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                }
                Divider()
                LabeledToolbar(label: deleteHoverLabel) {
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.deleteRow() },
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Row" : "Delete") }
                    ) {
                        DeleteRow()
                    }
                    .disabled(!selectionState.isInTable)
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.deleteCol() },
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Column" : "Delete") }
                    ) {
                        DeleteCol()
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.deleteTable() },
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Table" : "Delete") }
                    ) {
                        DeleteTable()
                    }
                    .disabled(!selectionState.isInTable)
                }
                Divider()
                Spacer()
            }
            Divider()
        }
        .frame(height: toolbarPreference.height())
        .padding([.leading, .trailing], 8)
        .padding([.top, .bottom], 2)
        .background(Blur(style: .systemUltraThinMaterial))
    }
    
}
