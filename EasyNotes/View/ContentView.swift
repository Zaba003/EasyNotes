//
//  ContentView.swift
//  EasyNotes
//
//  Created by Кирилл Заборский on 23.09.2021.
//

import SwiftUI
import Firebase
import MarkupEditor


struct CircleData: Hashable {
    let width: CGFloat
    let opacity: Double
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ContentView : View {
    
    @ObservedObject var Notes = getNotes()
    @State var show = false
    @State var txt = ""
    @State var docID = ""
    @State var remove = false
    
    // MARK: - Button Setting
    
    @State private var isAnimating: Bool = false
    var color: Color
    var systemImageName: String
    var buttonWidth: CGFloat
    var numberOfOuterCircles: Int
    var animationDuration: Double
    var circleArray = [CircleData]()
    
    
    init(color: Color = Color.orange, systemImageName: String = "plus.circle.fill",  buttonWidth: CGFloat = 60, numberOfOuterCircles: Int = 2, animationDuration: Double  = 1) {
        self.color = color
        self.systemImageName = systemImageName
        self.buttonWidth = buttonWidth
        self.numberOfOuterCircles = numberOfOuterCircles
        self.animationDuration = animationDuration
        
        var circleWidth = self.buttonWidth
        var opacity = (numberOfOuterCircles > 4) ? 0.40 : 0.20
        
        for _ in 0..<numberOfOuterCircles{
            circleWidth += 20
            self.circleArray.append(CircleData(width: circleWidth, opacity: opacity))
            opacity -= 0.05
        }
    }
    
    // MARK: - Body
    
    var body : some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HStack {
                    Text("Easy Notes").font(.title).foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        self.remove.toggle()
                    }) {
                        Image(systemName: self.remove ? "xmark.circle" : "trash").resizable().frame(width: 23, height: 23).foregroundColor(.white)
                    }
                    
                }.padding()
                    .padding(.top,UIApplication.shared.windows.first?.safeAreaInsets.top)
                    .background(Color.orange)
                
                
                if self.Notes.data.isEmpty {
                    if self.Notes.noData {
                        Spacer()
                        Text(LocalizedStringKey("No Notes !!!"))
                        Spacer()
                        
                    } else {
                        
                        Spacer()
                        Indicator()
                        Spacer()
                    }
                    
                } else {
                    // MARK: - ScrollView element
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack{
                            ForEach(self.Notes.data) { item in
                                HStack(spacing: 15) {
                                    Button(action: {
                                        self.docID = item.id
                                        self.txt = item.note
                                        self.show.toggle()
                                    }) {
                                        VStack(alignment: .leading, spacing: 12) {
                                            let formatNote = item.note.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                                                .replacingOccurrences(of: "&[^;]+;", with:
                                                                        "", options:.regularExpression, range: nil)
                                            Text(item.date)
                                            if formatNote != "" {
                                                Text(formatNote).lineLimit(1)
                                            } else { Text(LocalizedStringKey("Blank note")).lineLimit(1).foregroundColor(.gray) }
                                            Divider()
                                        }.padding(10)
                                            .foregroundColor(.black)
                                    }
                                    
                                    if self.remove {
                                        Button(action: {
                                            let db = Firestore.firestore()
                                            db.collection("notes").document(item.id).delete()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }.padding(.horizontal)
                            }
                        }
                    }
                }
            }.edgesIgnoringSafeArea(.top)
            
            // MARK: - Button Add Note
            
            ZStack {
                Group {
                    ForEach(circleArray, id: \.self) { cirlce in
                        Circle()
                            .fill(self.color)
                            .opacity(self.isAnimating ? cirlce.opacity : 0)
                            .frame(width: cirlce.width, height: cirlce.width, alignment: .center)
                            .scaleEffect(self.isAnimating ? 1 : 0.01)
                    }
                }
                .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true),
                           value: self.isAnimating)
                
                Button(action: {
                    self.txt = ""
                    self.docID = ""
                    self.show.toggle()
                    
                }) {
                    Image(systemName: self.systemImageName)
                        .resizable()
                        .scaledToFit()
                        .background(Circle().fill(Color.white))
                        .frame(width: self.buttonWidth, height: self.buttonWidth, alignment: .center)
                        .accentColor(color)
                    
                }
                .onAppear(perform: {
                    self.isAnimating.toggle()
                })
            }
        }.sheet(isPresented: self.$show) {
            
            // MARK: - Call EditView
            
            EditView(dataText: $txt, documentID: $docID, show: $show)
            
        }.animation(.default)
    }
}

struct Indicator : UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
    }
}
