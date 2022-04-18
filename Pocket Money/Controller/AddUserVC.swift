//
//  AddUserVC.swift
//  Pocket Money
//
//  Created by Danit on 17/02/2022.
//

import UIKit
import Firebase
import SwiftUI

class AddUserVC: UIViewController, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldSum: UITextField!
    @IBOutlet weak var selectColor: UIButton!
    @IBOutlet weak var userPicture: UIImageView!

    let storage = Storage.storage().reference()
    var path = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAnywhere)))

        textFieldName.placeholder = "New user name"
        textFieldSum.keyboardType = .alphabet
        
        textFieldSum.placeholder = "New amount of money (numbers only)"
        textFieldSum.keyboardType = .numberPad
        
        userPicture.image = UIImage(named: "userIcon")

        let tapedUserPicture = UITapGestureRecognizer(target: self, action: #selector(tapedUserPicture))
        userPicture.isUserInteractionEnabled = true
        userPicture.addGestureRecognizer(tapedUserPicture)

        
    }
    
    @objc func tapedUserPicture() {
 
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        
        path = "userPicture/\(textFieldName.text).png"
        
        storage.child(path).putData(imageData , metadata: nil) { _, error in
            guard error == nil else {
                print("failed to upload ")
                return
            }
            
            self.storage.child(self.path).downloadURL { url, error in
                guard let url = url, error == nil else {return}
            self.path = url.absoluteString
                
                DispatchQueue.main.async {
                    self.userPicture.image = image
                }
                
            print("downdload URL: \(self.path)")
            UserDefaults.standard.set(self.path, forKey: "url")
            }
        }
    }
    
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func tapAnywhere(sender: UITapGestureRecognizer){
            print("tapped")
            view.endEditing(true)
    }
    
    @IBAction func addUserButtonPressed(_ sender: UIButton) {
        
        if let userName = self.textFieldName.text, let userSum = Int(self.textFieldSum.text!) {
            let db = Firestore.firestore()
            
            // Add a new document in collection "users"
            db.collection("users").document(userName).setData([
                "name": userName,
                "sum": userSum,
                "pictureURL": path,
                "add_every": 0,
                "constant_amount_to_add": 0,
                "date_to_begin": 0])
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
    
        } else {
            // What will happen if there is no name and sum - pop up message "you didnt enter name and sum".
            // name and sum vibrate
            // do nothing
        }
        
        _ = navigationController?.popViewController(animated: true)

        
    }
    
    
    
    
}


