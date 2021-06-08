//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Tanner Heath on 5/21/21.
//

import Foundation

struct LoginResponse: Codable {
    let session: Session
    let account: Account
}

struct Account: Codable {
    let registered: Bool
    let key: String
}

struct Session: Codable {
    let id: String
    let expiration: String
}

