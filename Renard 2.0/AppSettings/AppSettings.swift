//
//  AppSettings.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 29/05/25.
//

import SwiftUI

struct AppSettings: View {
    @AppStorage("deleteAfterSave") private var shouldDeleteAfterSave = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack{
            Color.renardBackgroundHeavy.ignoresSafeArea()
            VStack(alignment: .leading){
                HStack{
                    Text(LocalizedStringKey("deleteAfterSaveOne"))
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Toggle("", isOn: $shouldDeleteAfterSave)
                        .labelsHidden()
                        .padding()
                }
                .background(Color.renardBoldBlue)
                .padding(.vertical, 1.0)
                HStack{
                    Text("preferencesOption2")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.white)
                        .padding()
                    Text(LocalizedStringKey("preferencesOption2_0"))
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(Color.renardBoldBlue)
                Spacer()
            }
        }
        .background(Color.renardDarkBlue.ignoresSafeArea())
        .toolbarBackground(Color.renardDarkBlue, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(LocalizedStringKey("preferences"))
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    AppSettings()
}
