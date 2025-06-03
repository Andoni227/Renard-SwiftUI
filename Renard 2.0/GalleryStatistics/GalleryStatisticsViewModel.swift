//
//  GalleryStatisticsViewModel.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 31/05/25.
//

import Foundation

class StatisticsViewModel: ObservableObject {
    let maxResPhoto: AssetObject?
    let lowResPhoto: AssetObject?
    let mostCommonFormat: ImageType?
    let lessCommonFormat: ImageType?
    let totalPhotos: Int
    let formatCounts: [FormatObject]

    init(photos: [AssetObject]) {
        self.totalPhotos = photos.count
        self.maxResPhoto = photos.max(by: { $0.resolution < $1.resolution })
        self.lowResPhoto = photos.min(by: { $0.resolution < $1.resolution })

        var countDict: [ImageType: Int] = [:]
        for photo in photos {
            countDict[photo.format, default: 0] += 1
        }

        let sorted = countDict
            .map { FormatObject(id: UUID(), imageType: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })

        self.formatCounts = sorted
        self.mostCommonFormat = sorted.first?.imageType
        self.lessCommonFormat = sorted.last?.imageType
    }
    
    func getSections() -> RenardSectionElements{
        var sections: RenardSectionElements = []
        
        let formatsSectionElements = formatCounts.map({ RenardSectionElement(id: UUID(), title: $0.imageType.name, components: [$0.count.description]) })
        
        sections.append(RenardSectionElement(id: UUID(), title: "MaxResPhoto", components: ["\(maxResPhoto?.resolution ?? 0) MP"]))
        sections.append(RenardSectionElement(id: UUID(), title: "MinusResPhoto", components: ["\(lowResPhoto?.resolution ?? 0) MP"]))
        sections.append(RenardSectionElement(id: UUID(), title: "MostCommonFormat", components: [mostCommonFormat?.name ?? "-"]))
        sections.append(RenardSectionElement(id: UUID(), title: "LessCommonFormat", components: [lessCommonFormat?.name ?? "-"]))
        sections.append(RenardSectionElement(id: UUID(), title: "TotalPhotos", components: ["\(totalPhotos)"]))
        sections += formatsSectionElements
        
        return sections
    }
}
