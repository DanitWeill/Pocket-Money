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
    @IBOutlet weak var progressView: UIProgressView!
    
    let storage = Storage.storage().reference()
    var path = String()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAnywhere)))

        textFieldName.placeholder = "New user name"
        textFieldSum.keyboardType = .alphabet
        
        textFieldSum.placeholder = "New amount of money (numbers only)"
        textFieldSum.keyboardType = .numberPad
        
        selectColor.addTarget(self, action: #selector(didTapSelectColor), for: .touchUpInside )
        
        userPicture.image = UIImage(named: "userIcon")
        progressView.isHidden = true
        
        let tapedUserPicture = UITapGestureRecognizer(target: self, action: #selector(tapedUserPic))
        userPicture.isUserInteractionEnabled = true
        userPicture.addGestureRecognizer(tapedUserPicture)

        
    }
    
    @objc func didTapSelectColor() {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true )
        
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
      
       
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        
        //save a string of the chosen color, and then add it to the db in add user button
        
    }
    
    
    @objc func tapedUserPic() {
        
        print("=======================")
 
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
        
        activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.style = .gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
        
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
        
        progressView.isHidden = false

        let taskRefrence = storage.child(path).putData(imageData , metadata: nil) { _, error in
            guard error == nil else {
                print("failed to upload ")
                return
            }
            
            
            self.storage.child(self.path).downloadURL { url, error in
                guard let url = url, error == nil else {return}
            self.path = url.absoluteString
                
                DispatchQueue.main.async {
                    self.userPicture.image = image
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                
            print("downdload URL: \(self.path)")
            UserDefaults.standard.set(self.path, forKey: "url")
            }
        }
        // the snapshot tells about the current state of the upload
        taskRefrence.observe(.progress) { snapshot in
            guard let pctThere = snapshot.progress?.fractionCompleted else {return}
            print("you are \(pctThere) complete")
            self.progressView.progress = Float(pctThere)
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
                "cellColor": String(),
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


