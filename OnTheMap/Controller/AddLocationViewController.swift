//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var objectId: String?
    
    //Sets textField delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        websiteTextField.delegate = self
    }
    
    //Sets activityIndicator state
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.isHidden = true
    }
    
    //MARK: IBActions
    
    //Dismisses the current view when back button is pressed
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Stages location and link to be submitted
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
    
    //MARK: Functions
    
    //Geocodes the location submitted
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
    
    //Loads location with student information
    private func loadNewLocation(_ coordinate: CLLocationCoordinate2D) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoadLocationVC") as! LoadLocationViewController
        controller.studentInformation = buildStudentInfo(coordinate)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //Creates an instance of StudentInformation
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
    
    //Handles return button on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //Handles activityIndicator animation
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
