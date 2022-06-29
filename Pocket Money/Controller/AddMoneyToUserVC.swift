//
//  AddMoneyToUserVC.swift
//  Pocket Money
//
//  Created by Danit on 06/02/2022.
//

import UIKit
import Firebase

class AddMoneyToUserVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    
    var nameToPass: String = ""
    var rateToPass = Float()

    let db = Firestore.firestore()
    var dateMoneyAdded = String()
    var amountAdded = Int()
    var currency = "ILS"
//    var finalAmountOfMoneyToAddToSum = DateCalculate().finalAmountOfMoneyToAdd
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        
        guard let uid = Auth.auth().currentUser?.uid else {return}

        db.collection("families").document(uid).collection("kids").document(nameToPass).getDocument { doc, err in
            if let err = err{
                print(err.localizedDescription)
            }else{
                if doc?.data()?["sum"] != nil{
                    let data = doc?.data()?["sum"] as? Float
                }
            }
        }
        
        nameLabel.text = "Add money to  \(nameToPass)  pocket"
        
        amountTextField.keyboardType = .numberPad
        
      
        db.collection("families").document(uid).getDocument { doc, err in
            if let err = err{
                print(err)
            } else {
                self.currency = doc?.data()?["currency"] as? String ?? "ILS"
                self.currencyLabel.text = self.currency
            }
        }
    }
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        
        if amountTextField.text != ""{
            amountAdded = Int(amountTextField.text!)!
        amountTextField.text = ""
        
        //read from db and transaction
            guard let uid = Auth.auth().currentUser?.uid else {return}

        let sumReference = db.collection("families").document(uid).collection("kids").document(nameToPass)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sumReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldSum = sfDocument.data()?["sum"] as? Float else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            //update sum in db
            var amountAddedRate = Float(self.amountAdded) / self.rateToPass
          
            transaction.updateData(["sum": oldSum + Float(amountAddedRate)], forDocument: sumReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                
                
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.timeZone = .current
                formatter.locale = .current
                formatter.dateFormat = "MMM d, yyyy"
//                dd.MM.yyyy   HH:mm
                self.dateMoneyAdded = formatter.string(from: date)
                
                //set new collection "history"
                UserDetailsVC().dateArray = []
                sumReference.collection("history").addDocument(data: [
                    "date money added": self.dateMoneyAdded,
                    "amount added": self.amountAdded,
                    "date": Date().timeIntervalSince1970,
                    "currency": self.currency
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        if let dateMoneyAdded = self.dateMoneyAdded as? String, let amoundToAdd = self.amountAdded as? Int, let currencyAdded = self.currency as? String {
                            let newDate = DateAmount(dateMoneyAdded: dateMoneyAdded, amountAdded: Float(amoundToAdd), currencyAdded: currencyAdded)
                            UserDetailsVC().dateArray.append(newDate)
                            
                        }
                    }
                    
                    
                }
            }
                
                //notification center
                NotificationCenter.default.post(name: Notification.Name("sumUpdate"), object: nil)
                
                NotificationCenter.default.post(name: Notification.Name("dateUpdate"), object: nil)
                
            }
            view.endEditing(true)
            
            self.showToast(message: "Added!", font: .systemFont(ofSize: 12.0))
            
            
            dismiss(animated: true)
        } else {
            self.showToast(message: "Please enter amount", font: .systemFont(ofSize: 12.0))

        }
       
    }
        
    
    @objc func tap(sender: UITapGestureRecognizer){
        print("tapped")
        view.endEditing(true)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addByTimeVC = segue.destination as? AddByTimeVC {
            addByTimeVC.nameToPass = nameToPass
        }
    }
        
}

extension AddMoneyToUserVC {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.green.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 3.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
