//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        websiteTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        activityIndicatorAnimation(animating: true)
        
        let newLocation = locationTextField.text
        
        guard let url = URL(string: self.websiteTextField.text!), UIApplication.shared.canOpenURL(url) else {
            self.showAlert(message: "Please include 'http://' in your link.", title: "Invalid URL")
            activityIndicatorAnimation(animating: false)
            return
        }
        
        geocodeLocation(newLocation: newLocation ?? "")
    }
    
    private func geocodeLocation (newLocation: String) {
        CLGeocoder().geocodeAddressString(newLocation) { (marker, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription, title: "Location Not Found")
                self.activityIndicatorAnimation(animating: false)
            } else {
                var location: CLLocation?
                
                if let marker = marker, marker.count > 0 {
                    location = marker.first?.location
                }
                
                if let location = location {
                    self.loadNewLocation(location.coordinate)
                } else {
                    self.showAlert(message: "Please try again later.", title: "Error")
                    self.activityIndicatorAnimation(animating: false)
                }
            }
        }
    }
    
    private func loadNewLocation(_ coordinate: CLLocationCoordinate2D) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoadLocationVC") as! LoadLocationViewController
        controller.studentInformation = buildStudentInfo(coordinate)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func buildStudentInfo(_ coordinate: CLLocationCoordinate2D) -> StudentInformation {

        var studentInfo = [
            "uniqueKey": OTMClient.Auth.key,
            "firstName": OTMClient.Auth.firstName,
            "lastName": OTMClient.Auth.lastName,
            "mapString": locationTextField.text!,
            "mediaURL": websiteTextField.text!,
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            ] as [String: AnyObject]

        if let objectId = objectId {
            studentInfo["objectId"] = objectId as AnyObject
        }

        return StudentInformation(studentInfo)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    private func activityIndicatorAnimation(animating: Bool) {
        if animating == true {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
}
