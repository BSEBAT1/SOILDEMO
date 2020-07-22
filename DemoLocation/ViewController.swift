//
//  ViewController.swift
//  DemoLocation
//
//  Created by Berkay Sebat on 7/22/20.
//  Copyright © 2020 SoilConnect. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController{
    
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var textViewConstraint: NSLayoutConstraint!
    
    private let geoCoder = CLGeocoder()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideFilterView))
        self.mapView.addGestureRecognizer(tapGesture)
        
    }
    
    func askForLocationPermissions() {
        let alertController = UIAlertController(title: "Location Needed", message: "Please go to Settings and turn on the location permissions", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            askForLocationPermissions()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @objc func hideFilterView() {
        
        self.textViewConstraint.constant = 60
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        if (CLLocationManager.locationServicesEnabled())
        {
            CLLocationManager.authorizationStatus()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            askForLocationPermissions()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let user = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        user.canShowCallout = true
        user.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return user
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let coordinate =  mapView.userLocation.location else {return}
        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) in
            if let first = placemarks?.first {
                DispatchQueue.main.async {
                    guard let name = first.name, let postal = first.postalCode, let counter = first.country else {return}
                    self.textView.text = "Address: \(name) Zip: \(postal) Country: \(counter)"
                    self.textView.translatesAutoresizingMaskIntoConstraints = false
                    self.textViewConstraint.constant = 0
                    UIView.animate(withDuration: 0.5) { [weak self] in
                                   self?.view.layoutIfNeeded()
                               }
                }
                
            }
        }
    }
}





