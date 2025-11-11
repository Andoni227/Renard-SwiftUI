//
//  MapView.swift
//  Renard 2.0
//
//  Created by Andoni Suarez on 19/08/25.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView: View {
    let location: CLLocationCoordinate2D
    @State private var camera = MapCameraPosition.automatic
    
    var body: some View {
        Map(position: $camera){
            Marker("", coordinate: location)
        }
        .mapStyle(.hybrid)
        .mapStyle(.standard(elevation: .automatic))
        .onTapGesture {
            if UserDefaults.standard.value(forKey: "preferedMaps") as? String ?? "Apple Maps" == "Google Maps" {
                if let mapURL = URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.latitude)%2C\(location.longitude)") {
                    UIApplication.shared.open(mapURL)
                }
            }else{
                var mapItem: MKMapItem?
                if #available(iOS 26.0, *) {
                    mapItem = MKMapItem(location: CLLocation(latitude: location.latitude, longitude: location.longitude), address: nil)
                } else {
                    mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
                }
                mapItem?.name = "📷"
                mapItem?.url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(location.latitude)%2C\(location.longitude)")
                mapItem?.openInMaps()
            }
        }
        .onAppear{
            camera = MapCameraPosition.region(MKCoordinateRegion(center: location, latitudinalMeters: 100.0, longitudinalMeters: 100.0))
        }
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        MapView(location: CLLocationCoordinate2D(latitude: 19.7027, longitude: -99.194475))
    }
}
