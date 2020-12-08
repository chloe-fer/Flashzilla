//
//  SettingsView.swift
//  Flashzilla
//
//  Created by Chloe Fermanis on 10/10/20.
//

import SwiftUI


struct SettingsView: View {
    
    @Environment (\.presentationMode) var presentationMode
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        
        NavigationView {
            
            Form {
                Section(header: Text("SETTINGS")) {
                    Toggle(isOn: $settings.repeatWrongCards, label: {
                        Text("Repeat Incorrect Cards")
                    })
                }
            }
            .navigationBarTitle(Text("Settings"))
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
