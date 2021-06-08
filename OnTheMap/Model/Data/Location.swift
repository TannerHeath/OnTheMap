//
//  Location.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/31/21.
//

import Foundation

struct Location: Codable {
    let objectId: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String
}
