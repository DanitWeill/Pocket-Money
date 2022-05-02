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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))

//        navigationItem.leftBarButtonItem?.customView?.isHidden = false
    }
    
    @objc func tap(sender: UITapGestureRecognizer){
            print("tapped")
            view.endEditing(true)
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
    
      
    if let email = usernameTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e)
                } else {
                    
                    
                    
                    self.performSegue(withIdentifier: "goToMainVC", sender: nil)
                    
//                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC") as? MainVC
//                    {
//                        let navVc = UINavigationController(rootViewController: vc)
//
//                        self.present(navVc, animated: true, completion: nil)
//                    }
                    
                    
                }
            }
        }
    }
    
}
