//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    //MARK: IBOutlets
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentsList()
    }
    
    //MARK: IBActions
    
    //Refreshes table information
    @IBAction func refreshButtonAction(_ sender: Any) {
        getStudentsList()
    }
    
    //Deletes the current user session and dismisses to the login screen
    @IBAction func logoutButtonAction(_ sender: Any) {
        OTMClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Functions
    
    //
    func getStudentsList(){
        OTMClient.getStudentLocations { (studentInformation, error) in
            if studentInformation.isEmpty != true {
                    MapModel.studentInfo = studentInformation
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
            } else {
                self.showAlert(message: error?.localizedDescription ?? "There was an error downloading the information", title: "Error")
            }
        }
    }
    
    //MARK: tableView Functions
    
    //Sets number of sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Sets number of rows in table equal to the count of studentInfo
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapModel.studentInfo.count
    }
    
    //Populates table cell with student information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationTableViewCell")!
        let student = MapModel.studentInfo[indexPath.row]
        let first = student.firstName
        let last = student.lastName
        cell.textLabel?.text = "\(first) \(last)"
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    //Opens the student's submitted link when the cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = MapModel.studentInfo[indexPath.row]
        openLink(student.mediaURL ?? "")
    }

}
