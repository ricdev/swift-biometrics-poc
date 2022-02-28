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
        
        Biometrics.shared.authenthicate(completion: { result in
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
