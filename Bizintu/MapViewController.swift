//
//  ViewController.swift
//  Bizintu
//
//  Created by Austin Wei on 11/7/17.
//  Copyright © 2017 Bizintu. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var profilePic: UIImageView!
    
    var locationManager = CLLocationManager()
    
    var firstLoad = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width / 2;
        self.profilePic.clipsToBounds = true
        
        // Do any additional setup after loading the view, typically from a nib.
        mapView.settings.myLocationButton = true
        mapView.settings.indoorPicker = true
        
        mapView.delegate = self
        
        mapView.isMyLocationEnabled = true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        //locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func pickPlace(_ sender: UIButton) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        
        present(placePicker, animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("Place name \(place.name)")
        print("Place address \(place.formattedAddress)")
        print("Place attributions \(place.attributions)")
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        
        print("No place selected")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated")
        if (firstLoad)
        {
            let location = locations.last
            
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
            
            self.mapView.camera = camera;
            firstLoad = false
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        
        let modifiedname = name.replacingOccurrences(of: "\n", with: " ")
        
        let infoMarker = GMSMarker()
        
        infoMarker.position = location
        infoMarker.title = modifiedname
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        
        /*var tempPlace = MeetingPlace(id: placeID, name: modifiedname, loc: location)
        
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            infoMarker.snippet = ""
            
            if let address = place.formattedAddress {
                infoMarker.snippet?.append(address + "\n")
                tempPlace.setAddress(address: address)
            }
            if let number = place.phoneNumber {
                infoMarker.snippet?.append(number)
                tempPlace.setPhone(num: number)
            }
        })*/
        
        mapView.selectedMarker = infoMarker
    }
    
    


}

