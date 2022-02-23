//
//  signinViewController.swift
//  Pocket Money
//
//  Created by Danit on 01/02/2022.
//

import UIKit
import Firebase

class SigninVC: UIViewController {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    @IBAction func signinButton(_ sender: UIButton) {
        if let email = usernameTextField.text, let password = passwordTextField.text {
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "signinToMainVC", sender: self)
                }
            }
        }
    }
}


