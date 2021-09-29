//
//  EasyNotesApp.swift
//  EasyNotes
//
//  Created by Кирилл Заборский on 23.09.2021.
//

import SwiftUI
import Firebase

@main
struct EasyNotesApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    class Host : UIHostingController<ContentView> {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
    }
}
