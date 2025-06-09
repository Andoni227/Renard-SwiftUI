//
//  MainDashboardBottomView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 09/06/25.
//

import SwiftUI

struct MainDashboardBottomView: View {
    
    @Binding var photoSize: String
    @Binding var deleteAfterSave: Bool
    var btnAction: () -> Void
    
    var body: some View {
        VStack{
            Spacer()
            HStack {
                Spacer()
                ZStack{
                    Color.renardBoldBlue
                        .frame(width: 130.0, height: 40.0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 10.0)
                    
                    Button(action: btnAction) {
                        Image(systemName: "square.and.arrow.down.fill")
                            .renderingMode(.template)
                            .imageScale(.large)
                            .tint(.white)
                        
                        Text("save")
                            .font(.custom(RenardFont.Bold.rawValue, size: 15.0))
                            .foregroundColor(.white)
                    }
                    .background(Color.renardBoldBlue)
                    .padding()
                }
            }
            
            HStack{
                RNRDText(text: "deleteAfterSave \(photoSize)")
                    .background(Color.renardDarkBlue)
                    .padding(.vertical, 15.0)
                Toggle("", isOn: $deleteAfterSave)
                    .frame(width: 100.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8.0)
            .background(Color.renardDarkBlue)
        }
    }
}
