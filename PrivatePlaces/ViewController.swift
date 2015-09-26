//
//  ViewController.swift
//  PrivatePlaces
//
//  Created by Zackery leman on 8/18/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        let initialLocation = CLLocation(latitude: 37.4520420, longitude: -122.1374890)
        centerMapOnLocation(initialLocation)
        let results = getSecretLocations()
        mapView.addAnnotations(results)
          checkLocationAuthorizationStatus()
        
    }
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func getSecretLocations() -> [SecretPlace]{
        var  places:[SecretPlace] = []
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount(GlobalConstants.locationStore)
        if let result = dictionary {
            for (placeName,coords) in result {
                let coordString = (coords as! String).componentsSeparatedByString(",")
                
                let lat = CLLocationDegrees((coordString.first as! NSString).doubleValue)
                let long = CLLocationDegrees((coordString.last as! NSString).doubleValue)
                places.append(SecretPlace(name: placeName as! String,lat: lat , long: long,temp: CLLocationCoordinate2D(latitude: lat, longitude: long)))
            }
            
        } else {
            println(error)
        }
        
        return places
    }
    
    @IBAction func addNewPlace(sender: UIBarButtonItem) {
        newSecretPlace(mapView.userLocation.location,name: "Newest Location")
    }
    
    
    func newSecretPlace(location:CLLocation,name:String) {
        
        
        let content = "\(location.description)"
        
        let (dictionary, error) = Locksmith.loadDataForUserAccount(GlobalConstants.locationStore)
        
        
        if let existingData = dictionary as? [String:String] {
            var data = existingData
            data[name] = content
            if let error = Locksmith.updateData(data, forUserAccount: GlobalConstants.locationStore){
                println(error)
            } else {
                let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
                mapView.removeAnnotations( annotationsToRemove )
                mapView.addAnnotations(getSecretLocations())
            }
            
        }
        
    }
 
}

extension ViewController: CLLocationManagerDelegate {

//    // MARK: - Location
//    
//    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
//        NSLog("Error while updating location %@",error.localizedDescription)
//    }
//    
//    
//    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//               //centerMapOnLocation(initialLocation)
//       println("Got locaiton \(locations.description)")
//    }
//    
}
extension ViewController: MKMapViewDelegate {
    
    // 1
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? SecretPlace {
            let identifier = "secretLocation"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
            }
            return view
//        } else if let annotation = annotation as? MKUserLocation  {
//             var view: MKPinAnnotationView
//            return view
//            
        }
        return nil
    }
}
