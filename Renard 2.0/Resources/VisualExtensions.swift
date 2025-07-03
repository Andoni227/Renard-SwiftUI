//
//  VisualExtensions.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 24/05/25.
//

import SwiftUI


struct TitleFormatView: View{
    let imageFormat: FormatObject
    @Binding var selectedFormat: ImageType?
    
    var body: some View{
        Button(action: {
            selectedFormat = imageFormat.imageType
        }){
            Text("\(imageFormat.imageType.name) \(imageFormat.count)")
                .font(.custom("Montserrat", size: 13.0))
                .foregroundColor(selectedFormat == imageFormat.imageType ? .white : .black)
                .padding(.horizontal, 10)
                .frame(height: 35)
                .background(selectedFormat == imageFormat.imageType ? Color.renardBackgroundHeavy : Color.white)
                .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))
        }
    }
}

struct RNRDText: View{
    var text: LocalizedStringKey
    var alignment: TextAlignment = .leading
    var size: CGFloat = 15.0
    var font: RenardFont = RenardFont.Medium
    
    var body: some View{
        Text(text)
        .font(.custom(font.rawValue, size: size))
        .foregroundColor(.white)
        .multilineTextAlignment(alignment)
    }
}

struct RenardButton: View {
    let title: LocalizedStringKey
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .font(.custom("Montserrat-Medium", size: 16))
                .multilineTextAlignment(.leading)
                .padding()
                .background(Color.renardBackgroundHeavy)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct RenardSectionList: View{
    var sections: RenardSectionElements
    @Binding var selectedAsset: AssetObject?
    
    var body: some View {
        List{
            ForEach(sections) { section in
                Button(action: {
                    if let asset = section.selectedAsset{
                        selectedAsset = asset
                    }
                }){
                    HStack{
                        Text(LocalizedStringKey(section.title))
                            .font(.custom("Montserrat-Bold", size: 16))
                            .foregroundColor(.white)
                            .font(.headline)
                            .background(Color.renardDarkBlue)
                        
                        Spacer()
                        
                        ForEach(section.components, id: \String.self) { component in
                            Text(LocalizedStringKey(component))
                                .foregroundColor(.white)
                                .font(.custom("Montserrat-Medium", size: 16))
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 8.0)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .listRowBackground(Color.renardDarkBlue)
                .background(Color.renardDarkBlue)
            }
        }
        .listStyle(.plain)
        .background(Color.renardDarkBlue.ignoresSafeArea())
    }
}

typealias RenardSectionElements = [RenardSectionElement]
struct RenardSectionElement: Identifiable{
    var id: UUID
    var title: String
    var components: [String]
    var selectedAsset: AssetObject?
}


struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View{
    func getElementsInScreen(for size: CGFloat) -> Int{
        return Int(UIScreen.main.bounds.width / size)
    }
}

extension Color {
    static let renardBackgroundHeavy = Color(red: 9/255, green: 12/255, blue: 17/255)
    static let renardDarkBlue = Color(red: 48/255, green: 68/255, blue: 99/255)
    static let renardBoldBlue = Color(red: 91/255, green: 123/255, blue: 173/255)
    static let renardMediumBlue = Color(red: 74/255, green: 90/255, blue: 127/255)
    
    static var random: Color {
           Color(
               red: .random(in: 0...1),
               green: .random(in: 0...1),
               blue: .random(in: 0...1)
           )
       }
}

enum RenardFont: String{
    case Light = "Montserrat-Light"
    case Medium = "Montserrat-Medium"
    case Bold = "Montserrat-Bold"
    case Regular = "Montserrat-Regular"
}
