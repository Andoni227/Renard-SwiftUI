//
//  GalleryStatistics.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 30/05/25.
//

import SwiftUI

struct GalleryStatistics: View {
    @EnvironmentObject var dashboardVM: MainDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let statsVM = StatisticsViewModel(photos: dashboardVM.photos)
        ZStack{
            Color.renardDarkBlue.ignoresSafeArea()
            RenardSectionList(sections: statsVM.getSections())
                .padding()
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
                Text(LocalizedStringKey("StatisticsScreenTitle"))
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    GalleryStatistics()
        .environmentObject(MainDashboardViewModel())
}

