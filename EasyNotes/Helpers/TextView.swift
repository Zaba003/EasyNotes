//
//  TextView.swift
//  EasyNotes
//
//  Created by Кирилл Заборский on 29.09.2021.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var text: NSAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        UITextView()
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.backgroundColor = UIColor.systemBackground
        uiView.attributedText = text
        uiView.spellCheckingType = .no
        uiView.autocorrectionType = .no
    }
}
