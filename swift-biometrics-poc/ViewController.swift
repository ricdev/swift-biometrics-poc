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
        
        /*
         
         Simulated login button in a typical login process.
         At the end of the process, a token will be received.
         Token will be enrypted and decrypted when needed.
         
         */

        // Store login data in Keychain
        UserDefaults.standard.set("user", forKey: "usernameKey")
        UserDefaults.standard.set("pass", forKey: "passwordKey")

        // check if user has log in successfully
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        print("\(hasLoginKey)")
        
        if hasLoginKey {
            
            // use face or touch id. typical execution is, after a successfull login, app ask the user if he/she wants this feature to be activated.
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
                    
                    self?.loadToken()
                }
            }
            
        } else {
            
            // login using username and password
            guard let usernameKey = UserDefaults.standard.string(forKey: "usernameKey"), let passwordKey = UserDefaults.standard.string(forKey: "passwordKey") else {
                self.alert(title: "Login Problem", message: "Wrong username or password", okActionTitle: "Continue")
                return
            }
            
            self.verify(username: usernameKey, password: passwordKey, completion: { (status, token) in
                
                guard status else {
                    self.alert(title: "Login Problem", message: "Wrong username or password", okActionTitle: "Continue")
                    self.lblTitle.text = "Failed. \nTap to try again."
                    return
                }
                
                self.lblTitle.text = "Success. \nTap to try again."
                
                guard let token = token else { return }
                saveToken(token: token)
                
                loadToken()
            })
            
        }
    }
}

extension ViewController {
    
    func saveToken(token: String) {

        // encrypt
        let data = HasherAESGCM.shared.enryptString(token)
        
        // save to local
        UserDefaults.standard.set(data, forKey: "loginKey")
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
    }
    
    func loadToken() {
        
        // get local data
        let defaults = UserDefaults.standard
        let loginKeyData = defaults.object(forKey: "loginKey") as? Data
        
        // Note: works only stored strings, bool etc.
        // let loginKeyData = UserDefaults.standard.data(forKey: "loginKey")
        
        guard let loginKeyData = loginKeyData else {
            self.alert(title: "Failed.", message: "Failed to load token.", okActionTitle: "Continue")
            self.lblTitle.text = "Failed. \nTap to try again."
            return
        }
        
        // decrypt
        let decryptedData: String? = HasherAESGCM.shared.decrypt(data: loginKeyData)
        
        guard let decryptedData = decryptedData else {
            self.alert(title: "Failed.", message: "Failed to load token.", okActionTitle: "Continue")
            self.lblTitle.text = "Failed. \nTap to try again."
            return
        }
        
        self.alert(title: "Success.", message: "Token: \(decryptedData)", okActionTitle: "Continue")
        self.lblTitle.text = "Success. \nTap to try again."
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
