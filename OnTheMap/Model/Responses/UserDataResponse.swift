//
//  UserDataResponse.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/22/21.
//

import Foundation

class UserDataResponse: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
}
