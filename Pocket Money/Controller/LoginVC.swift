//
//  signinViewController.swift
//  Pocket Money
//
//  Created by Danit on 01/02/2022.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
     
    
    @IBAction func loginButton(_ sender: UIButton) {
    
    if let email = usernameTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "loginToMainVC", sender: self)
                }
            }
        }
    }
    
}
