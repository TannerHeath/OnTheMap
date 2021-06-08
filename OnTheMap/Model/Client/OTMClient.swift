//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/21/21.
//

import Foundation

//MARK: Client

//Client for API connection
class OTMClient {
    struct Auth {
        static var sessionId = ""
        static var key = ""
        static var firstName = ""
        static var lastName = ""
        static var objectId = ""
    }
    
    //Get and Post URLs
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case signup
        case logout
        case userData
        case studentLocations
        case addLocation
        case updateLocation
        
        var stringValue: String {
            switch self {
            case .login: return Endpoints.base + "/session"
            case .signup: return "https://auth.udacity.com/sign-up"
            case .logout: return Endpoints.base + "/session"
            case .userData: return Endpoints.base + "/users/" + Auth.key
            case .studentLocations: return Endpoints.base + "/StudentLocation?limit=100&order=-updatedAt"
            case .addLocation: return Endpoints.base + "/StudentLocation"
            case .updateLocation: return Endpoints.base + "/StudentLocation/" + Auth.objectId
                
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: POST REQUESTS
    
    //Login function
    class func login (email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
        NetworkHelpers.taskForPostRequest(url: Endpoints.login.url, body: body, apiType: "Udacity", responseType: LoginResponse.self, httpMethod: "POST") { (response, error) in
            if let response = response {
                Auth.sessionId = response.session.id
                Auth.key = response.account.key
                getLoggedInUserData { (success, error) in
                    if success {
                        print("Logged in user's data fetched")
                    }
                    completion(true, nil)
                }
            } else {
                completion(false, error)
            }
    
    }
}
    //Adds student location
    class func addStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        NetworkHelpers.taskForPostRequest(url: Endpoints.addLocation.url, body: body, apiType: "", responseType: AddLocationResponse.self, httpMethod: "POST") { (response, error) in
            if let response = response, response.createdAt != nil {
                Auth.objectId = response.objectId ?? ""
                completion(true, nil)
            }
            completion(false, error)
        }
    }
    
    //MARK: DELETE REQUESTS
    
    //Deletes session
    class func logout(completion: @escaping() -> Void) {
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil {
            print(error!)
              return
          }
          let range = 5..<data!.count
          let newData = data?.subdata(in: range)
          print(String(data: newData!, encoding: .utf8)!)
            Auth.sessionId = ""
            completion()
        }
        task.resume()
        
    }
    
    //MARK: GET REQUESTS
    
    //Gets user data
    class func getLoggedInUserData(completion: @escaping(Bool, Error?) -> Void){
        NetworkHelpers.taskForGetRequest(url: Endpoints.userData.url, responseType: UserDataResponse.self, apiType: "Udacity") { (response, error) in
            if let response = response {
                Auth.firstName = response.firstName
                Auth.lastName = response.lastName
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    //Gets student locations and returns and array of locations
    class func getStudentLocations(completion: @escaping([StudentInformation], Error?) -> Void){
        NetworkHelpers.taskForGetRequest(url: Endpoints.studentLocations.url, responseType: StudentLocationsResponse.self, apiType: "") { (response, error) in
            if let response = response{
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    //MARK: PUT REQUESTS
    
    //Updates student location
    class func updateStudentLocation(information: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = "{\"uniqueKey\": \"\(information.uniqueKey ?? "")\", \"firstName\": \"\(information.firstName)\", \"lastName\": \"\(information.lastName)\",\"mapString\": \"\(information.mapString ?? "")\", \"mediaURL\": \"\(information.mediaURL ?? "")\",\"latitude\": \(information.latitude ?? 0.0), \"longitude\": \(information.longitude ?? 0.0)}"
        NetworkHelpers.taskForPostRequest(url: Endpoints.updateLocation.url, body: body, apiType: "", responseType: UpdateLocationResponse.self, httpMethod: "PUT") { (response, error) in
            if let response = response, response.updatedAt != nil {
                completion(true, nil)
            }
            completion(false, error)
        }
    }
}
