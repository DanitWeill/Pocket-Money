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
    @IBOutlet weak var nameLabel2: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    
    var nameToPass: String = ""
    var sumToPass: String = ""
    var newSum = Int()
    
    let db = Firestore.firestore()
    var dateMoneyAdded = String()
    var amountToAdd = Int()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("users").document(nameToPass).getDocument { doc, err in
            if let err = err{
                print(err.localizedDescription)
            }else{
                if doc?.data()?["sum"] != nil{
                    let data = doc?.data()?["sum"] as? Int
                    self.updateUISum(sum: data ?? 0)
                }
            }
        }
        
        nameLabel.text = nameToPass
        nameLabel2.text = nameToPass
        sumLabel.text = sumToPass
        
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        //UI
        let sum = Int(sumToPass)
        let amountToAdd = Int(amountTextField.text!)
        let newSum = sum! + amountToAdd!
        amountTextField.text = ""
        sumLabel.text = String(newSum)
        
        //read from db
        let sumReference = db.collection("users").document(nameToPass)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sumReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldSum = sfDocument.data()?["sum"] as? Int else {
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
            transaction.updateData(["sum": oldSum + amountToAdd!], forDocument: sumReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                
                self.updateUISum(sum: newSum)
                
                
                let date = Date()
                let formatter = DateFormatter()
                formatter.timeZone = .current
                formatter.locale = .current
                formatter.dateFormat = "dd.MM.yyyy   HH:mm"
                self.dateMoneyAdded = formatter.string(from: date)
                
                //set new collection "history"
                UserDetailsVC().dateArray = []
                sumReference.collection("history").addDocument(data: [
                    "date money added": self.dateMoneyAdded,
                    "amount to add": amountToAdd!,
                    "date": Date().timeIntervalSince1970
                   ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                        if let dateMoneyAdded = self.dateMoneyAdded as? String, let amoundToAdd = amountToAdd {
                            let newDate = DateAmount(dateMoneyAdded: dateMoneyAdded, amountAdded: amoundToAdd)
                            UserDetailsVC().dateArray.append(newDate)
                            
                        }
                }
                
                
              
                       
                }
   
                
                //notification center
                NotificationCenter.default.post(name: Notification.Name("sumUpdate"), object: nil)
                self.sumLabel.text = String(newSum)
                
                NotificationCenter.default.post(name: Notification.Name("dateUpdate"), object: nil)
              
                }
        }
        
        
    }
    
    func updateUISum(sum: Int) {
        sumLabel.text = String(sum)
    }
  
}

