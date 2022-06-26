//
//  DateCalculate.swift
//  Pocket Money
//
//  Created by Danit on 10/03/2022.
//

import Foundation
import Firebase


class DateCalculate{
    
    let db = Firestore.firestore()
    
    let date = Date()
    var timesToAdd = 0
    var finalAmountOfMoneyToAdd = 0
    
    func dateCalculate(nameOfKid: String ,constantAmountToAdd: Int, addEvery: Int, dateToBegin: TimeInterval) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
      
        // Calculate how often to add money
        let now = self.date.timeIntervalSince1970
        
        if dateToBegin == 0 && addEvery == 0 && constantAmountToAdd == 0{
            self.finalAmountOfMoneyToAdd = 0
        } else if now <= dateToBegin {
            self.finalAmountOfMoneyToAdd = 0
            
        } else if now > dateToBegin {
            
            let distance = Int((now - dateToBegin) / 86400)
            
            if distance >= addEvery{
                
               let numOfAdds = Int(distance / addEvery)
                
                self.finalAmountOfMoneyToAdd = numOfAdds * constantAmountToAdd
        
                let sfReference = db.collection("families").document(uid).collection("kids").document(nameOfKid)

                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    let sfDocument: DocumentSnapshot
                    do {
                        try sfDocument = transaction.getDocument(sfReference)
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

                    // Note: this could be done without a transaction
                    //       by updating the population using FieldValue.increment()
                    
                    print("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$")
                    transaction.updateData(["sum": oldSum + self.finalAmountOfMoneyToAdd], forDocument: sfReference)
                    transaction.updateData(["date_to_begin": now], forDocument: sfReference)
                    return nil
                }) { (object, error) in
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            }
        }
        print("=======5555555==============5555555=============")
//        print("final amount to add completion \(finalAmountOfMoneyToAdd)")
    }
}
        

