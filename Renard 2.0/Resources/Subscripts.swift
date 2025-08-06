//
//  Subscripts.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 29/07/25.
//

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    subscript(safe range: Range<Index>) -> SubSequence {
        let lower = Swift.max(range.lowerBound, startIndex)
        let upper = Swift.min(range.upperBound, endIndex)
        return lower < upper ? self[lower..<upper] : self[endIndex..<endIndex]
    }
    
    subscript(safe range: ClosedRange<Index>) -> SubSequence {
        let lower = Swift.max(range.lowerBound, startIndex)
        let upper = Swift.min(range.upperBound, index(after: endIndex))
        return lower <= upper ? self[lower...upper] : self[endIndex..<endIndex]
    }
}

@dynamicMemberLookup
struct JSON {
    let data: [String: Any]
    
    subscript<T>(dynamicMember member: String) -> T? {
        let specialKeys = ["TIFF", "GPS", "Exif", "MakerApple", "ExifAux"]
        let key = specialKeys.contains(member) ? "{\(member)}" : member
        let value = data[key]
        if let nestedDict = value as? [String: Any]{
            return JSON(data: nestedDict) as? T
        }else{
            return value as? T
        }
    }
}

@propertyWrapper
struct Capitalized {
    private var value: [String]

    var wrappedValue: [String] {
        get { value }
        set { value = newValue.map({ $0.capitalized })}
    }

    init(wrappedValue: [String]) {
        self.value = wrappedValue.map({ $0.capitalized })
    }
}
