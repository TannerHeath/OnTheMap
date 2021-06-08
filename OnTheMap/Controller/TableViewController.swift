//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/20/21.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentsList()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        getStudentsList()
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        OTMClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapModel.studentInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentLocationTableViewCell")!
        let student = MapModel.studentInfo[indexPath.row]
        let first = student.firstName
        let last = student.lastName
        cell.textLabel?.text = "\(first) \(last)"
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = MapModel.studentInfo[indexPath.row]
        openLink(student.mediaURL ?? "")
    }

}
