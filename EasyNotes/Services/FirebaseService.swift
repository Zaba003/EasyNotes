//
//  FirebaseService.swift
//  EasyNotes
//
//  Created by Кирилл Заборский on 23.09.2021.
//

import SwiftUI
import Firebase

class getNotes : ObservableObject {
    
    @Published var data = [Note]()
    @Published var noData = false
    
    init() {
        let db = Firestore.firestore()
        db.collection("notes").order(by: "date", descending: false).addSnapshotListener { (snap, error) in
            
            if error != nil {
                print((error?.localizedDescription)!)
                self.noData = true
                return
            }
            
            if (snap?.documentChanges.isEmpty)! {
                self.noData = true
                return
            }
            
            for item in snap!.documentChanges {
                if item.type == .added{
                    let id = item.document.documentID
                    let notes = item.document.get("notes") as! String
                    let date = item.document.get("date") as! Timestamp
                    let format = DateFormatter()
                    format.dateFormat = "dd.MM.YYYY HH:mm"
                    let dateString = format.string(from: date.dateValue())
                    self.data.append(Note(id: id, note: notes, date: dateString))
                }
                
                if item.type == .modified {
                    let id = item.document.documentID
                    let notes = item.document.get("notes") as! String
                    for item in 0..<self.data.count {
                        if self.data[item].id == id {
                            self.data[item].note = notes
                        }
                    }
                }
                
                if item.type == .removed {
                    let id = item.document.documentID
                    for item in 0..<self.data.count {
                        if self.data[item].id == id {
                            self.data.remove(at: item)
                            if self.data.isEmpty {
                                self.noData = true
                            }
                            return
                        }
                    }
                }
            }
        }
    }
}
