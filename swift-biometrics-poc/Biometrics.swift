//
//  Biometrics.swift
//  swift-biometrics-poc
//
//  Created by Ricardo Monteverde on 2/28/22.
//

import UIKit
import LocalAuthentication

class Biometrics {
    
    enum Status: String {
        case success
        case error
        case unavailable
    }
    
    static let shared = Biometrics()
    
    func authenthicate(completion: @escaping (Biometrics.Status) -> Void) {
        
        let context = LAContext()
        var error: NSError? = nil
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Authorize with touch id!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                
                guard success, error == nil else {
                    
                    completion(Status.error)
                    return
                }
                
                completion(Status.success)
            }
        } else {
            
            completion(Status.unavailable)
            return
        }
    }
}
