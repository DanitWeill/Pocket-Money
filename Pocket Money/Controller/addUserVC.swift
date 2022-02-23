//
//  addUserVC.swift
//  Pocket Money
//
//  Created by Danit on 17/02/2022.
//

import UIKit
import Firebase

class addUserVC: UIViewController {
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldSum: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldName.placeholder = "New user name"
        textFieldSum.keyboardType = .alphabet
        
        textFieldSum.placeholder = "New amount of money (numbers only)"
        textFieldSum.keyboardType = .numberPad
    }
    
    
    @IBAction func addUserButtonPressed(_ sender: UIButton) {
        
        if let userName = self.textFieldName.text, let userSum = Int(self.textFieldSum.text!) {
            let db = Firestore.firestore()
            
            // Add a new document in collection "users"
            db.collection("users").document(userName).setData([
                "name": userName,
                "sum": userSum])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    //what will happen if the name and sum are nil
                    //create a popping messege
                } else {
                    print("Document successfully written!")
                    print(userSum)
                    print(userName)
                    MainVC().users = []
                    
                    NotificationCenter.default.post(name: Notification.Name("newUserUpdate"), object: nil)

                }
            }
    
        }
        
        _ = navigationController?.popViewController(animated: true)

        
    }
    
    
    
    
}
