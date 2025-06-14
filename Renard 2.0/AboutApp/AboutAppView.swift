//
//  AboutApp.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 27/05/25.
//

import SwiftUI
import StoreKit

struct AboutAppView: View {
    @StateObject private var viewModel = AboutAppViewModel()
    @EnvironmentObject var dashboardVM: MainDashboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.faqs) { faq in
                    DisclosureGroup {
                        Text(LocalizedStringKey(faq.answer))
                            .font(.custom("Montserrat-Medium", size: 14))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                            .multilineTextAlignment(.leading)
                    } label: {
                        Text(LocalizedStringKey(faq.question))
                            .font(.custom("Montserrat-Medium", size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .tint(.white)
                    .padding()
                    .background(Color.renardBackgroundHeavy)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                RenardButton(title: "InfoScreen6Subtitle", action: {
                    if let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                })
                
                DisclosureGroup {
                    RenardButton(title: "Solitudinem - LottieFiles ↗️", action: {
                        if let url = URL(string: "https://lottiefiles.com/solitudinem") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    })
                    
                    RenardButton(title: "Cảnh Ngô - LottieFiles ↗️", action: {
                        if let url = URL(string: "https://lottiefiles.com/canhngo") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    })
                } label: {
                    Text("InfoScreen7Subtitle")
                        .font(.custom("Montserrat-Medium", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                }
                .tint(.white)
                .padding()
                .background(Color.renardBackgroundHeavy)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                RenardButton(title: "InfoScreen8Subtitle", action: {
                    if let url = URL(string: "https://www.renardapp.dev") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                })
                
                RenardButton(title: "InfoScreen9Subtitle", action: {
                    if let url = URL(string: "https://www.renardapp.dev/politica-de-privacidad") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                })

                Spacer()
                HStack {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("V \(version)")
                            .foregroundColor(.white)
                            .font(.custom("Montserrat-Medium", size: 16))
                            .padding()
                            .background(Color.renardBackgroundHeavy)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                RNRDText(text: "Renard", size: 16)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Router.preferences) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(value: Router.statistics) {
                    Image(systemName:  "chart.bar.fill")
                        .imageScale(.large)
                        .foregroundColor(.white)
                }
            }
        }
        .navigationDestination(for: Router.self, destination: { route in
            switch route{
            case .preferences:
                AppSettings()
            case .statistics:
                GalleryStatistics()
            }
        }) 
        .background(Color.renardDarkBlue.ignoresSafeArea())
        .navigationTitle("Renard")
        .preferredColorScheme(.dark)
    }
}

#Preview {
    AboutAppView()
}
