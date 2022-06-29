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
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var selectColorButton: UIButton!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let db = Firestore.firestore()

    var currencyName = "ILS"
    let storage = Storage.storage().reference()
    var picturePath = String()
    var cellColor = UIColor(hexString: "#ffe747")
    var rateToPass = Float()

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAnywhere)))
        
        textFieldName.placeholder = "Kid name"
        textFieldName.keyboardType = .alphabet
        
        
        textFieldSum.placeholder = "Starting amount"
        textFieldSum.keyboardType = .numberPad
        checkCurrentCurrency()
        
        errorLabel.isHidden = true
        
        selectColorButton.addTarget(self, action: #selector(didTapSelectColor), for: .touchUpInside )
        
        userPicture.image = UIImage(named: "userIcon")
        progressView.isHidden = true
        
        let tapedUserPicture = UITapGestureRecognizer(target: self, action: #selector(tapedUserPic))
        userPicture.isUserInteractionEnabled = true
        userPicture.addGestureRecognizer(tapedUserPicture)
    }
    
    
    func checkCurrentCurrency() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        db.collection("families").document(uid).getDocument { document, error in
            if let error = error {
                print(error)
            }
            self.currencyName = document?.data()?["currency"] as! String
            self.currencyLabel.text = self.currencyName
        }
    }
    
    //color
    @objc func didTapSelectColor() {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        present(colorPickerVC, animated: true )
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        cellColor = viewController.selectedColor
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        cellColor = viewController.selectedColor
        selectColorButton.backgroundColor = cellColor
    }
    
    
    @objc func tapedUserPic() {
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
        
        picturePath = "userPicture/\(textFieldName.text).png"
        
        progressView.isHidden = false
        
        let taskRefrence = storage.child(picturePath).putData(imageData , metadata: nil) { _, error in
            guard error == nil else {
                print("failed to upload ")
                return
            }
            
            self.storage.child(self.picturePath).downloadURL { url, error in
                guard let url = url, error == nil else {return}
                self.picturePath = url.absoluteString
                DispatchQueue.main.async {
                    self.userPicture.image = image
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                
                print("downdload URL: \(self.picturePath)")
                UserDefaults.standard.set(self.picturePath, forKey: "url")
            }
        }
        // the snapshot tells about the current state of the upload
        taskRefrence.observe(.progress) { snapshot in
            guard let picLoadThere = snapshot.progress?.fractionCompleted else {return}
            print("you are \(picLoadThere) complete")
            
            self.progressView.progress = Float(picLoadThere)
            if picLoadThere == 1.0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                    self.progressView.isHidden = true
                }
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
        if textFieldName.text != "" && textFieldSum.text != "" {
            
            if let kidName = self.textFieldName.text, let kidSum = Float(self.textFieldSum.text!) {
            let db = Firestore.firestore()
            guard let uid = Auth.auth().currentUser?.uid else {return}

            // Add a new document in collection "families"
            db.collection("families").document(uid).collection("kids").document(kidName).setData([
                "name": kidName,
                "sum": kidSum / rateToPass,
                "cellColor": self.cellColor.htmlRGBColor,
                "pictureURL": self.picturePath,
                "add_every": 0,
                "constant_amount_to_add": 0,
                "date_to_begin": 0])
            { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    MainVC().kids = []
                    
                    NotificationCenter.default.post(name: Notification.Name("newUserUpdate"), object: nil)
                    
                }
            }
                //dismiss to mainvc
                _ = self.navigationController?.popViewController(animated: true)
                }
        } else {
        
            print("please fill in name and sum")
            errorLabel.isHidden = false
            errorLabel.text = "Please fill in Name and Sum"
            
            //vibrate
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator.impactOccurred()
           
        }
    }
    
    
}


extension UIColor {
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0,0,0,0)
    }
    // hue, saturation, brightness and alpha components from UIColor**
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return (hue,saturation,brightness,alpha)
        }
        return (0,0,0,0)
    }
    var htmlRGBColor:String {
        return String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255))
    }
    var htmlRGBaColor:String {
        return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
    }
}
