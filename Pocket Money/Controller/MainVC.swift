//
//  MainVC.swift
//  Pocket Money
//
//  Created by Danit on 01/02/2022.
//

import UIKit
import Firebase
import SwipeCellKit


class MainVC: UIViewController, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: [User] = []
    
    let date = Date()
    var timesToAdd = 0
    var finalAmountOfMoneyToAdd = 0
    var userImage = UIImage()
    
    let db = Firestore.firestore()
    
    var userIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCellIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("newUserUpdate"), object: nil)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("sumUpdate"), object: nil)
        
        loadUsers()
        
    }
    
    
    
    @objc func sumUpdateRecived(){
        
        loadUsers()
        
    }
    
    func loadUsers() {
        self.users = []
        db.collection("users").getDocuments { querySnapshot, error in
            if let e = error {
                print("Error getting documents: \(e)")
            } else {
                if let documents = querySnapshot?.documents {
                    
                    
                    var num = -1
                    
                    
                    for document in documents {
                        
                        num = num + 1
                        
                        let data = document.data()
                        
                        if let name = data["name"] as? String, let sum = data["sum"] as? Int {
                            
                            if document.data()["constant_amount_to_add"] != nil && document.data()["add_every"] != nil && document.data()["date_to_begin"] != nil{
                                
                                // Calculate how often to add money
                                let constantAmountToAdd = document.data()["constant_amount_to_add"] as? Int ?? 0
                                let addEvery = document.data()["add_every"] as? Int ?? 0
                                let  oldSum2 = document.data()["sum"] as? Int ?? 0
                                let dateToBegin = document.data()["date_to_begin"] as! TimeInterval
                                let now = self.date.timeIntervalSince1970
                                
                                if dateToBegin == 0 && addEvery == 0 && constantAmountToAdd == 0{
                                    self.finalAmountOfMoneyToAdd = 0
                                } else if
                                    now < dateToBegin {
                                    // number of days between now to date to begin as int
                                    self.timesToAdd = Int((dateToBegin - now) / 86400)
                                    self.finalAmountOfMoneyToAdd = self.timesToAdd / addEvery * constantAmountToAdd
                                    
                                } else if now > dateToBegin {
                                    self.timesToAdd = Int((dateToBegin + now) / 86400)
                                    self.finalAmountOfMoneyToAdd = self.timesToAdd / addEvery * constantAmountToAdd
                                    
                                }
                                
                                self.db.collection("users").document(name).setData(["final_amount_to_add" : self.finalAmountOfMoneyToAdd], merge: true) { err in
                                    if let err = err {
                                        print("Error writing document: \(err)")
                                        
                                    } else {
                                        
                                        let sumReference = self.db.collection("users").document(name)
                                        
                                        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
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
                                            
                                            
                                            transaction.updateData(["sum": oldSum + self.finalAmountOfMoneyToAdd], forDocument: sumReference)
                                            return nil
                                        }) { (object, error) in
                                            if let error = error {
                                                print("Transaction failed: \(error)")
                                            } else {
                                                print("Transaction finalSum successfully committed!")
                                                
                                                print(num)
                                                
                                                
                                                // Adding user picture
                                                if document.data()["pictureURL"] as? String != ""{
                                                    let imageURL = document.data()["pictureURL"] as? String
                                                    
                                                    let storage = Storage.storage().reference(forURL: imageURL!)
                                                    
                                                    storage.getData(maxSize: 5 * 1024 * 1024) { data, error in
                                                        if let error = error {
                                                            
                                                            self.userImage = UIImage(named: "userIcon")!
                                                            print(error.localizedDescription)
                                                            
                                                            let newUser = User(name: name, sum: oldSum2 + self.finalAmountOfMoneyToAdd, picture: self.userImage)
                                                            
                                                            self.users.append(newUser)
                                                            self.tableView.reloadData()
                                                        } else {
                                                            
                                                            self.userImage = UIImage(data: data!)!
                                                            
                                                            let newUser = User(name: name, sum: oldSum2 + self.finalAmountOfMoneyToAdd, picture: self.userImage)
                                                            
                                                            self.users.append(newUser)
                                                            self.tableView.reloadData()
                                                        }
                                                    }
                                                    
                                                }else{
                                                    self.userImage = UIImage(named: "userIcon")!
                                                    
                                                    let newUser = User(name: name, sum: oldSum2 + self.finalAmountOfMoneyToAdd, picture: self.userImage)
                                                    
                                                    self.users.append(newUser)
                                                    self.tableView.reloadData()
                                                }
                                                
                                                
                                                
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToAddUserVC", sender: self)
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        performSegue(withIdentifier: "goToHomePage", sender: self)
    }
    
    
    
}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCellIdentifier", for: indexPath) as! UserCell
        
        cell.delegate = self
        
        cell.nameLabel.text = users[indexPath.row].name
        cell.sumLabel.text = String(users[indexPath.row].sum)
        
        let backgroundColor = [UIColor.red, UIColor.orange, UIColor.purple, UIColor.blue, UIColor.green, UIColor.yellow]
        
        for color in backgroundColor {
            cell.color.backgroundColor = backgroundColor[indexPath.row]
        }
        
        
        cell.userPicture.image = users[indexPath.row].picture
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        performSegue(withIdentifier: "goToUserDetailsVC", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userDetailsVC = segue.destination as? UserDetailsVC {
            userDetailsVC.usersStringToPass = users
            userDetailsVC.userIndex = userIndex
        }
    }
    
    
}

extension MainVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("item deleted")
            
            self.db.collection("users").document(self.users[indexPath.row].name).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.users = []
            self.loadUsers()
            tableView.reloadData()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
}
//
//extension String {
//    func toImage() -> UIImage? {
//        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
//            return UIImage(data: data)
//        }
//        return nil
//    }
//}
