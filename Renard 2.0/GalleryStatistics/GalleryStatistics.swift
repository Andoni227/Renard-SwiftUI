//
//  GalleryStatistics.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 30/05/25.
//

import SwiftUI
import Charts

struct GalleryStatistics: View {
    @EnvironmentObject var dashboardVM: MainDashboardViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedAsset: AssetObject? = nil
    
    var body: some View {
        let statsVM = StatisticsViewModel(photos: dashboardVM.photos)
        ZStack{
            Color.renardDarkBlue.ignoresSafeArea()
            VStack{
                if #available(iOS 17.0, *) {
                    Chart(statsVM.formatCounts, id: \.id) { element in
                        SectorMark(
                            angle: .value("", element.count),
                            innerRadius: .ratio(0.618),
                            outerRadius: .inset(10),
                            angularInset: 1
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("", element.imageType.name))
                    }
                    .preferredColorScheme(.dark)
                    .padding()
                    .frame(width: 350, height: 350)
                }
                RenardSectionList(sections: statsVM.getSections(), selectedAsset: $selectedAsset)
                    .padding()
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
                Text(LocalizedStringKey("StatisticsScreenTitle"))
                    .font(.custom("Montserrat-Medium", size: 16))
                    .foregroundColor(.white)
            }
        }
        .sheet(item: $selectedAsset){ asset in
            NavigationStack{
                PhotoPreview(asset: asset)
            }
        }
    }
}
