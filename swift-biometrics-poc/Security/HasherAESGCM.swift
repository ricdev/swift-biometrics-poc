//
//  HasherAESGCM.swift
//  swift-biometrics-poc
//
//  Created by Ricardo Monteverde on 3/10/22.
//

import Foundation
import CryptoKit

class HasherAESGCM {
    
    static let shared = HasherAESGCM()
    
    let protocolSalt = "Hashed user ID for Salt?".data(using: .utf8)!
    var symmetricKey: SymmetricKey? = nil
    let nonce = AES.GCM.Nonce()
    
    init() {
        generateKeyViaSecret()
    }
    
    func generateKeyViaSecret() {
        let secret = "256-bit-key-secret-key-goes-here"
        symmetricKey = SymmetricKey(data: secret.data(using: .utf8)!)

        // Note: Customizing Nonce
//        nonce = try! AES.GCM.Nonce(data: Data(base64Encoded: "fv1nixTVovpSvpdA")!)
    }
    
    func enryptString(_ value: String) -> Data? {
        guard let symmetricKey = self.symmetricKey else { return nil }
//        guard let nonce = self.nonce as? AES.GCM.Nonce else { return nil }
        
        // encrpt
        let valueToSecure = value.data(using: .utf8)!
        let encrypted = try! AES.GCM.seal(valueToSecure, using: symmetricKey, nonce: nonce).combined
        
        return encrypted
    }
    
    func decrypt(data: Data) -> Data? {
        guard let symmetricKey = self.symmetricKey else { return nil }
//        guard let nonce = self.nonce as? AES.GCM.Nonce else { return nil }
        
        // decrypt
        let sealedBox = try! AES.GCM.SealedBox(combined: data)
        let decrypted = try! AES.GCM.open(sealedBox, using: symmetricKey)
        
        return decrypted
    }
    
    func decrypt(data: Data) -> String? {
        guard let data: Data = self.decrypt(data: data) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
