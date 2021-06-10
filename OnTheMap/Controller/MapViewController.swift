//
//  ViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPins()
    }
    
    //MARK: IBActions
    
    //Deletes the current user session and dismisses to the login screen
    @IBAction func logoutButtonAction(_ sender: Any) {
        OTMClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //Refreshes map to display the most recent pins
    @IBAction func refreshButtonAction(_ sender: Any) {
        getPins()
    }
    
    //MARK: GET Map Pins
    
    //Function removes current annotations, gets student locations, and adds the annotation
    func getPins() {
        self.annotations.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        OTMClient.getStudentLocations { (locations, error) in
            for dictionary in locations {
               
                let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = dictionary.firstName
                let last = dictionary.lastName
                let mediaURL = dictionary.mediaURL
                
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                
                self.annotations.append(annotation)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
            }
        }
        
        
    }
    
    //MARK: mapView Functions
    
    //Checks to see if pin already exists. If not it creates a new instance.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
        let reusedId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId)
    
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView!.canShowCallout = true
            pinView!.tintColor = .blue
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView!
    }
    
    //Handles the accessoryView when the pin is tapped and opens the link that iis submitted
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                openLink(toOpen ?? "")
            }
        }
    }
    
}

