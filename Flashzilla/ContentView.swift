//
//  ContentView.swift
//  Flashzilla
//
//  Created by Chloe Fermanis on 10/10/20.
//

import SwiftUI

enum ActiveSheet {
    case settings, edit
}

class UserSettings: ObservableObject {
    @Published var repeatWrongCards = false
}

struct ContentView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled

    @EnvironmentObject var settings: UserSettings
    
    @State private var cards = [Card]()
    
    //@State private var showingEditScreen = false
    //@State private var showingSettingsScreen = false
    
    @State private var showingTimeOutAlert = false
    @State private var showSheet = false
    @State private var activeSheet: ActiveSheet = .settings
    
    @State private var timeRemaining = 100
    @State private var isActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image(decorative: "bkg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)

            VStack {
                
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.black)
                            .opacity(0.75)
                    )

                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        
                        // This card view struct has a trailing closure
                        // That asks for the card to be removed when set
                        // It gets set in the card view struct - when card is removed
                        CardView(card: self.cards[index]) { remove in
                           withAnimation {
                                if remove {
                                    self.removeCard(at: index)
                                } else {
                                    self.repeatCard(at: index)
                                    self.removeCard(at: index)

                                }
                           }
                        }
                        .stacked(at: index, in: self.cards.count)
                        //Ensures only top card accessible
                        .allowsHitTesting(index == self.cards.count - 1)
                        .accessibility(hidden: index < self.cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)

                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }

            VStack {
                
                HStack {
                    Spacer()

                    Button(action: {
                        showSheet = true
                        activeSheet = .edit

                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    //.sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
                    //    EditCards()
                    //}
                    
                    
                    Button(action: {
                        showSheet = true
                        activeSheet = .settings
                    }) {
                        Image(systemName: "gearshape")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                    //.sheet(isPresented: $showingSettingsScreen) {
                    //    SettingsView()
                    //}

                    
                }

                Spacer()
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()

            if differentiateWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button(action: {
                            withAnimation {
                                self.repeatCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect."))
                        Spacer()

                        Button(action: {
                            withAnimation {
                                self.removeCard(at: self.cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct."))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if self.cards.isEmpty == false {
                self.isActive = true
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
               if showSheet == true { return } else {
                    timeRemaining -= 1
                }
            } else {
                showingTimeOutAlert = true
            }
        }

        .alert(isPresented: $showingTimeOutAlert) {
            Alert(title: Text("Time Out"), message: Text("Keep learning, try again!"), dismissButton: .default(Text("OK")) { self.resetCards() })
        }
        .sheet(isPresented: $showSheet) {
            if self.activeSheet == .edit {
                EditCards()
            } else {
                SettingsView()
            }
        }
        .onAppear(perform: resetCards)
    }
    
    func repeatCard(at index: Int) {
        guard index >= 0 else { return }
        let card = cards[index]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cards.insert(card, at: 0)

        }
        //cards.remove(at: 0)


        if cards.isEmpty {
            isActive = false
        }
    }

    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        //print("\(settings.repeatWrongCards)")
       cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }

    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
}

// MARK: - Extension for creating a stack of views

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
