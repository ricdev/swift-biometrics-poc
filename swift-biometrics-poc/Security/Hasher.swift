//
//  Hasher.swift
//  swift-biometrics-poc
//
//  Created by Ricardo Monteverde on 3/9/22.
//  Resources: https://www.raywenderlich.com/10846296-introducing-cryptokit

import Foundation
import CryptoKit

class Hasher {
    
    static let shared = Hasher()

    let protocolSalt = "Hashed user ID for Salt?".data(using: .utf8)!
    var privateKey: Curve25519.KeyAgreement.PrivateKey? = nil
    var publicKey: Curve25519.KeyAgreement.PublicKey? = nil
    var symmetricKey: SymmetricKey? = nil
    
    init() {
        generateKeyPairs()
    }
    
    func generateKeyPairs() {
        // generate key pair
        self.privateKey = Curve25519.KeyAgreement.PrivateKey()
        guard let privateKey = self.privateKey else { return }

        // publish public key in trusted service
        TrustedService.shared.publishPublicKey(privateKey.publicKey, identity: "User with ID of 12345")
        
        // encrypting using keys
        publicKey = TrustedService.shared.fetchPublicKey(identity: "User with ID of 12345")
        guard let publicKey = publicKey else { return }
        
        // generate a symmetry key, Key-agreement protocol https://en.wikipedia.org/wiki/Key-agreement_protocol
        let sharedSecret = try! privateKey.sharedSecretFromKeyAgreement(with: publicKey)
        
        symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(using: SHA256.self, salt: protocolSalt, sharedInfo: Data(), outputByteCount: 32)
        
        // Note: when app restarts, generated symmetricKey encounters error in decrypt
        // Thread 1: Fatal error: 'try!' expression unexpectedly raised an error: CryptoKit.CryptoKitError.authenticationFailure
    }
    
    func enryptString(_ value: String) -> Data? {
        guard let symmetricKey = self.symmetricKey else { return nil }
        
        // encrpt
        let valueToSecure = value.data(using: .utf8)!
        let encrypted = try! ChaChaPoly.seal(valueToSecure, using: symmetricKey).combined
        
        return encrypted
    }
    
    func decrypt(data: Data) -> Data? {
        guard let symmetricKey = self.symmetricKey else { return nil }
        
        // decrypt
        let sealedBox = try! ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try! ChaChaPoly.open(sealedBox, using: symmetricKey)
        
        return decryptedData
    }
    
    func decrypt(data: Data) -> String? {
        guard let data: Data = self.decrypt(data: data) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// TODO: Integrate with an external process
class TrustedService {
    
    static let shared = TrustedService()
    
    var key: Curve25519.KeyAgreement.PublicKey?
    var identity: String = ""
    
    func publishPublicKey(_ publicKey: Curve25519.KeyAgreement.PublicKey, identity: String) {
        self.key = publicKey
        self.identity = identity
    }
    
    func fetchPublicKey(identity: String) -> Curve25519.KeyAgreement.PublicKey? {
        if identity == self.identity {
            return self.key
        } else {
            return nil
        }
    }
}
