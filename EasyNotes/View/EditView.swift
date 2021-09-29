//
//  EditView.swift
//  EasyNotes
//
//  Created by Кирилл Заборский on 23.09.2021.
//

import SwiftUI
import Firebase
import MarkupEditor
import UniformTypeIdentifiers

struct EditView: View {
    
    @Binding var dataText: String
    @Binding var documentID : String
    @Binding var show : Bool
    
    private let markupEnv = MarkupEnv(style: .labeled)
    private var selectedWebView: MarkupWKWebView? { markupEnv.observedWebView.selectedWebView }
    private let showSubToolbar = ShowSubToolbar()
    @State private var rawText = NSAttributedString(string: "")
    @State private var pickerShowing: Bool = false
    @State private var rawShowing: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack() {
                Spacer()
                Button(action: {
                    self.show.toggle()
                    self.SaveData()
                }) {
                    Text("Save").padding(.vertical).padding(.horizontal,25).foregroundColor(.white)
                }.background(Color.orange)
                    .clipShape(Capsule())
                    .padding()
            }
            MarkupWebView(markupDelegate: self, initialContent: dataText)
            Divider()
            ScrollView(.horizontal, showsIndicators: false) {
                MarkupToolbar(markupDelegate: self)
            }.padding(EdgeInsets(top: 2, leading: 8, bottom: 10, trailing: 8))
        }
        .environmentObject(showSubToolbar)
        .environmentObject(markupEnv.toolbarPreference)
        .environmentObject(markupEnv.selectionState)
        .environmentObject(markupEnv.observedWebView)
    }
    
    func SaveData() {
        dataText = rawText.string
        let db = Firestore.firestore()
        if self.documentID != "" {
            db.collection("notes").document(self.documentID).updateData(["notes":self.dataText]) { (error) in
                if error != nil{
                    print((error?.localizedDescription)!)
                    return
                }
            }
            
        } else {
            db.collection("notes").document().setData(["notes":self.dataText,"date":Date()]) { (error) in
                if error != nil{
                    print((error?.localizedDescription)!)
                    return
                }
            }
        }
    }
    
    private func setRawText(_ handler: (()->Void)? = nil) {
        selectedWebView?.getPrettyHtml { html in
            rawText = attributedString(from: html ?? "")
            handler?()
        }
    }
    
    private func attributedString(from string: String) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.label
        attributes[.font] = UIFont.monospacedSystemFont(ofSize: StyleContext.P.fontSize, weight: .regular)
        return NSAttributedString(string: string, attributes: attributes)
    }
}

extension EditView: MarkupDelegate {
    
    func markupDidLoad(_ view: MarkupWKWebView, handler: (()->Void)?) {
        markupEnv.observedWebView.selectedWebView = view
        setRawText(handler)
    }
    
    func markupInput(_ view: MarkupWKWebView) {
        setRawText()
    }
    
}
