//
//  Keychain.swift
//  swift-biometrics-poc
//
//  Created by Ricardo Monteverde on 3/9/22.
//

import Foundation

class Keychain {
    
    static let shared = Keychain()
    
    // Keychain Configuration
    struct KeychainConfiguration {
      static let serviceName = "TouchMeIn"
      static let accessGroup: String? = nil
    }
    
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    
}
