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
    @StateObject private var viewModel = AppSettingsViewModel()
    
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
                    Button(action: {
                        viewModel.showCompressionOptions = true
                    }, label: {
                        Text("preferencesOption2")
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .padding()
                        Text(viewModel.getCompression())
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                        Spacer()
                    })
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
        .confirmationDialog("preferencesOption2", isPresented: $viewModel.showCompressionOptions, titleVisibility: .visible) {
            Button("preferencesOption2_0") { viewModel.changeCompression(0.7) }
            Button("preferencesOption2_1") { viewModel.changeCompression(0.8) }
            Button("preferencesOption2_2") { viewModel.changeCompression(0.9) }
            Button("cancel", role: .cancel) {}
        }
    }
}

#Preview {
    AppSettings()
}
