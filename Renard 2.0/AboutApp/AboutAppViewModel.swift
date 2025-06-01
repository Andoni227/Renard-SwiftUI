//
//  AboutAppViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 28/05/25.
//

import SwiftUI

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

class AboutAppViewModel: ObservableObject {
    @Published var faqs: [FAQ] = [
        FAQ(question: "InfoScreen1Title", answer: "InfoScreen1Subtitle"),
        FAQ(question: "InfoScreen2Title", answer: "InfoScreen2Subtitle"),
        FAQ(question: "InfoScreen3Title", answer: "InfoScreen3Subtitle"),
        FAQ(question: "InfoScreen4Title", answer: "InfoScreen4Subtitle"),
        FAQ(question: "InfoScreen5Title", answer: "InfoScreen5Subtitle")
    ]
}
