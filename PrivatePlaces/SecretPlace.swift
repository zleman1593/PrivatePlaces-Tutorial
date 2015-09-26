//
//  SecretPlace.swift
//  PrivatePlaces
//
//  Created by Zackery leman on 8/18/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class SecretPlace: NSObject, MKAnnotation{
    var title:String!
    var location:CLLocation!
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, lat: CLLocationDegrees, long: CLLocationDegrees,  temp: CLLocationCoordinate2D){
        self.title = name
        self.location = CLLocation(latitude: lat, longitude: long)
        self.coordinate = temp
        super.init()
    }
}