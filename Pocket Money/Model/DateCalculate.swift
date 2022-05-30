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
    
    func dateCalculate(userName : String, constantAmountToAdd: Int, addEvery: Int, dateToBegin: TimeInterval, completion: @escaping (Int) -> Void){
      
        // Calculate how often to add money
        let now = self.date.timeIntervalSince1970
        
        if dateToBegin == 0 && addEvery == 0 && constantAmountToAdd == 0{
            self.finalAmountOfMoneyToAdd = 0
        } else if now < dateToBegin {
            // number of days between now to date to begin as int
            self.timesToAdd = Int(dateToBegin - now) / 86400
            self.finalAmountOfMoneyToAdd = self.timesToAdd / addEvery * constantAmountToAdd
            
        } else if now > dateToBegin {
            self.timesToAdd = Int((dateToBegin + now) / 86400)
            self.finalAmountOfMoneyToAdd = self.timesToAdd / addEvery * constantAmountToAdd
            
        }
        completion(finalAmountOfMoneyToAdd)
        
    }
}
        
//        //read from db
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//
//        db.collection("families").document(uid).collection("kids").document(userName).getDocument { doc, err in
//            if let err = err{
//                print(err.localizedDescription)
//            }else{
//                
//                if let constantAmountToAdd = doc?.data()?["constant_amount_to_add"], let addEvery = doc?.data()?["add_every"] as? Int, let dateToBegin = doc?.data()?["date_to_begin"]{
//                    
//                    let now = self.date.timeIntervalSince1970
//                    if now < dateToBegin as! TimeInterval {
//                    // number of days between now to date to begin as int
//                        self.timesToAdd = Int(dateToBegin as! TimeInterval - now) / 86400
//                    } else if now > dateToBegin as! TimeInterval {
//                        self.timesToAdd = Int(dateToBegin as! TimeInterval + now) / 86400
//                    }
//                    
//                    finalAmountOfMoneyToAdd = timesToAdd / addEvery * constantAmountToAdd
//
//                    
//                    
//                    
//                    
//                    self.db.collection("users").document(userName).setData(["final_amount_to_add" : self.finalAmountOfMoneyToAdd], merge: true) { err in
//                        if let err = err {
//                            print("Error writing document: \(err)")
//                            completion()
//                        } else {
//                            
//                            let sumReference = self.db.collection("users").document(userName)
//
//                            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
//                                let sfDocument: DocumentSnapshot
//                                do {
//                                    try sfDocument = transaction.getDocument(sumReference)
//                                } catch let fetchError as NSError {
//                                    errorPointer?.pointee = fetchError
//                                    return nil
//                                }
//
//                                guard let oldSum = sfDocument.data()?["sum"] as? Int else {
//                                    let error = NSError(
//                                        domain: "AppErrorDomain",
//                                        code: -1,
//                                        userInfo: [
//                                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
//                                        ]
//                                    )
//                                    errorPointer?.pointee = error
//                                    return nil
//                                }
//
//                                // Note: this could be done without a transaction
//                                //       by updating the population using FieldValue.increment()
//                                transaction.updateData(["sum": oldSum + self.finalAmountOfMoneyToAdd], forDocument: sumReference)
//                                return nil
//                            }) { (object, error) in
//                                if let error = error {
//                                    print("Transaction failed: \(error)")
//                                    completion()
//                                } else {
//                                    print("Transaction finalSum successfully committed!")
//                                    completion()
//                                }
//                            }
//                        }
//
//                    }
//                
//                }
//                
//            }
//        }
//        
//    }
//    
//    
//                    
//                }
//                
////                if doc?.data()?["constant_amount_to_add"] != nil && doc?.data()?["add_every"] != nil && doc?.data()?["date_to_begin"] != nil{
////
////
////                    let constantAmountToAdd = doc?.data()?["constant_amount_to_add"] as? Int ?? 0
////
////                    let addEvery = doc?.data()?["add_every"] as? Int ?? 0
////
////                    let dateToBegin = doc?.data()?["date_to_begin"] as! TimeInterval
////
////                    let now = self.date.timeIntervalSince1970
////
////                    if now < dateToBegin {
////                    // number of days between now to date to begin as int
////                    self.timesToAdd = Int((dateToBegin - now) / 86400)
////                    } else if now > dateToBegin {
////                        self.timesToAdd = Int((dateToBegin + now) / 86400)
////                    }
//                    
////                    self.finalAmountOfMoneyToAdd = self.timesToAdd / addEvery * constantAmountToAdd
//                    
//                    
////                    self.db.collection("users").document(userName).setData(["final_amount_to_add" : self.finalAmountOfMoneyToAdd], merge: true) { err in
////                        if let err = err {
////                            print("Error writing document: \(err)")
////                            completion()
////                        } else {
////
////                            let sumReference = self.db.collection("users").document(userName)
////
////                            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
////                                let sfDocument: DocumentSnapshot
////                                do {
////                                    try sfDocument = transaction.getDocument(sumReference)
////                                } catch let fetchError as NSError {
////                                    errorPointer?.pointee = fetchError
////                                    return nil
////                                }
////
////                                guard let oldSum = sfDocument.data()?["sum"] as? Int else {
////                                    let error = NSError(
////                                        domain: "AppErrorDomain",
////                                        code: -1,
////                                        userInfo: [
////                                            NSLocalizedDescriptionKey: "Unable to retrieve population from snapshot \(sfDocument)"
////                                        ]
////                                    )
////                                    errorPointer?.pointee = error
////                                    return nil
////                                }
////
////                                // Note: this could be done without a transaction
////                                //       by updating the population using FieldValue.increment()
////                                transaction.updateData(["sum": oldSum + self.finalAmountOfMoneyToAdd], forDocument: sumReference)
////                                return nil
////                            }) { (object, error) in
////                                if let error = error {
////                                    print("Transaction failed: \(error)")
////                                    completion()
////                                } else {
////                                    print("Transaction finalSum successfully committed!")
////                                    completion()
////                                }
////                            }
////                        }
////
////                    }
////
////                }
////
////            }
////        }
////
////    }
////
////
//}
