//
//  LoadLocationViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/31/21.
//

import UIKit
import MapKit

class LoadLocationViewController: UIViewController {

    var studentInformation: StudentInformation?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let studentLocation = studentInformation {
            let studentLocation = Location(objectId: studentLocation.objectId ?? "",
                                           uniqueKey: studentLocation.uniqueKey,
                                           firstName: studentLocation.firstName,
                                           lastName: studentLocation.lastName,
                                           mapString: studentLocation.mapString,
                                           mediaURL: studentLocation.mediaURL,
                                           latitude: studentLocation.latitude,
                                           longitude: studentLocation.longitude,
                                           createdAt: studentLocation.createdAt ?? "",
                                           updatedAt: studentLocation.updatedAt ?? ""
            )
            showLocations(location: studentLocation)
        }
        
    }
    
    @IBAction func addLocationButton(_ sender: Any) {
        if let studentLocation = studentInformation {
            if OTMClient.Auth.objectId == "" {
                OTMClient.addStudentLocation(information: studentLocation) { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                            }
                    }
                }
            } else {
                let alertVC = UIAlertController(title: "", message: "This student has already posted a location. Would you like to overwrite this location?", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action: UIAlertAction) in
                    OTMClient.updateStudentLocation(information: studentLocation) { (success, error) in
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlert(message: error?.localizedDescription ?? "", title: "Error")
                            }
                        }
                    }
                }))
                alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                    DispatchQueue.main.async {
                        alertVC.dismiss(animated: true, completion: nil)
                    }
                }))
                self.present(alertVC, animated: true)
            }
        }
    }
    
    
    private func showLocations(location: Location) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = getCoordinate(location: location) {
            let annotation = MKPointAnnotation()
            annotation.title = location.firstName! + location.lastName!
            annotation.subtitle = location.mediaURL ?? ""
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }

    private func getCoordinate(location: Location) -> CLLocationCoordinate2D?{
        if let lat = location.latitude, let lon = location.longitude {
            return CLLocationCoordinate2DMake(lat,lon)
        }
        return nil
    }

}
