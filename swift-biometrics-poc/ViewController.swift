//
//  ViewController.swift
//  swift-biometrics-poc
//
//  Created by Ricardo Monteverde on 2/28/22.
//

import UIKit

class ViewController: UIViewController {
    
    let lblTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.gray
        label.numberOfLines = 0
        label.text = "Tap to Start."
        // TODO: Add face id icon
        // button.setImage(UIImage(systemName: "faceid"),  for: .normal)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.lblTitle)
        NSLayoutConstraint.activate([
            self.lblTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            self.lblTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func tapGestureAction(sender : UITapGestureRecognizer) {
//        self.loginUsingV2()

        // Store login data in Keychain
        UserDefaults.standard.set("user", forKey: "usernameKey")
        UserDefaults.standard.set("pass", forKey: "passwordKey")
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
        UserDefaults.standard.set("0123456778", forKey: "loginKey")
        
        // get keychain data
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        print("\(hasLoginKey)")
        
        let loginKey = UserDefaults.standard.string(forKey: "loginKey")
        guard let loginKey = loginKey else { return }
        print("\(loginKey)")
        
        if let usernameKey = UserDefaults.standard.string(forKey: "usernameKey"), let passwordKey = UserDefaults.standard.string(forKey: "passwordKey") {
            
            self.verify(username: usernameKey, password: passwordKey, completion: { (status, token) in
                switch status {
                case true:
                    self.lblTitle.text = "Success. \nTap to try again."
                    
                    // Encrypt
                    guard let token = token else { return }
                    let data = Hasher.shared.enryptString(token)
                    
                    // Decrypt
                    guard let data = data else { return }
                    let decryptedData = Hasher.shared.decrypt(data: data)
                    
                    guard let decryptedData = decryptedData else { return }
                    print(decryptedData)
                    
                default:
                    self.lblTitle.text = "Failed. \nTap to try again."
                }
            })
        }
    }
}

extension ViewController {
    
    func verify(username: String, password: String, completion: (Bool, String?) -> Void) {
        let usernameKey = "user"
        let passwordKey = "pass"
        
        switch username == usernameKey && password == passwordKey {
        case true:
            return completion(true, "1234567")
        default:
            return completion(false, nil)
        }
    }
}

extension ViewController {
    
    func loginUsingV2() {
        BiometricsV2.shared.canEvaluate { (canEvaluate, _, canEvaluateError) in
            guard canEvaluate else {
                alert(title: "Error", message: canEvaluateError?.localizedDescription ?? "Face ID/Touch ID may not be configured.", okActionTitle: "Ok")
                return
            }
            
            BiometricsV2.shared.evaluate { [weak self] (success, error) in
                guard success else {
                    self?.alert(title: "Error", message: error?.localizedDescription ?? "Face ID/Touch ID may not be configured.", okActionTitle: "Ok")
                    return
                }
                
                self?.alert(title: "Success", message: "Verified", okActionTitle: "Continue")
            }
        }
    }
    
    func alert(title: String, message: String, okActionTitle: String) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: okActionTitle, style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}

extension ViewController {
    
    func loginUsingV1() {
        BiometricsV1.shared.authenthicate(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("result: \(result)")
                    self.lblTitle.text = "Success. \nTap to try again."
                case .error:
                    print("result: \(result)")
                    self.lblTitle.text = "Failed. \nTap to try again."
                case .unavailable:
                    print("result: \(result)")
                    self.lblTitle.text = "Biometrics unavailable. \nTap to try again."
                }
            }
        })
    }
}
