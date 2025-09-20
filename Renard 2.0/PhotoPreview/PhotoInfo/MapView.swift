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
            Marker("My Marker", coordinate: location)
        }
        .mapStyle(.hybrid)
        .mapStyle(.standard(elevation: .automatic))
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
