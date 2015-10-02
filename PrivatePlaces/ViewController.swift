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
        let initialLocation = getSecretLocations().last?.coordinate ??  CLLocationCoordinate2D(latitude: 37.4520420, longitude: -122.1374890)
        centerMapOnLocation(initialLocation)
        let results = getSecretLocations()
        mapView.addAnnotations(results)
        checkLocationAuthorizationStatus()
        
    }
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    
    func getSecretLocations() -> [SecretPlace]{
        var  places:[SecretPlace] = []
        
        let dictionary = Locksmith.loadDataForUserAccount(GlobalConstants.locationStore)
        if let result = dictionary {
            for (placeName,coords) in result {
                let coordString = (coords as! String).componentsSeparatedByString(",")
                let lat = CLLocationDegrees((coordString.first as! NSString).doubleValue)
                let long = CLLocationDegrees((coordString.last as! NSString).doubleValue)
                places.append(SecretPlace(name: placeName,lat: lat , long: long,temp: CLLocationCoordinate2D(latitude: lat, longitude: long)))
            }
            
        }
        
        return places
    }
    
    @IBAction func addNewPlace(sender: UIBarButtonItem) {
        if let currentLocation =  mapView.userLocation.location {
            centerMapOnLocation(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude))
            
            let alert = UIAlertController(title: "Current Location",
                message: "Give a Name to your new secret spot!",
                preferredStyle: .Alert)
            
            let saveAction = UIAlertAction(title: "Save",
                style: .Default) { [unowned self] (action: UIAlertAction!) -> Void in
                    
                    let textField = alert.textFields![0]
                    self.newSecretPlace(self.mapView.userLocation.location!,name: textField.text!)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel",
                style: .Default) { (action: UIAlertAction) -> Void in
            }
            
            alert.addTextFieldWithConfigurationHandler {
                (textField: UITextField!) -> Void in
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            presentViewController(alert,
                animated: true,
                completion: nil)
        }
        else {
              mapView.showsUserLocation = true
            let alert = UIAlertController(title: "Current Location Not Found",
                message: "Give the GPS a few more seconds to find you",
                preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel",
                style: .Default) { (action: UIAlertAction) -> Void in
            }
             alert.addAction(cancelAction)
            presentViewController(alert,
                animated: true,
                completion: nil)
        }
        
        
        
    }
    
    
    func newSecretPlace(location:CLLocation,name:String) {
        
        let content = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        
        var existingData = Locksmith.loadDataForUserAccount(GlobalConstants.locationStore) as? [String: String]
        
        
        if existingData == nil {
            existingData = [name:content]
        } else{
            existingData![name] = content
        }
        
        do {
            try  Locksmith.updateData(existingData!, forUserAccount: GlobalConstants.locationStore)
            let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
            mapView.removeAnnotations( annotationsToRemove )
            mapView.addAnnotations(getSecretLocations())
            
        } catch _ {
            print("error")
        }
        
        
        
    }
    
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      
           print("Got location \(locations.description)")
        }
    
}
extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? SecretPlace {
            let identifier = "secretLocation"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
}
