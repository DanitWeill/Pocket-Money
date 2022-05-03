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
    
    var name = String()
    var sum = Int()
    var oldSum2 = Int()
    var cellColor = UIColor(hexString: "#ffffff")
    var userImage = UIImage()
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let db = Firestore.firestore()
    
    var userIndex = Int()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil{
                
                
              
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as? Home
                {
                    self.present(vc, animated: true, completion: nil)
                }
                    
                
            }else{
                
                
                
                self.tableView.delegate = self
                self.tableView.dataSource = self
                
                self.navigationItem.setHidesBackButton(true, animated: true)
                
                self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCellIdentifier")
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.sumUpdateRecived), name: Notification.Name("newUserUpdate"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.sumUpdateRecived), name: Notification.Name("sumUpdate"), object: nil)
                
                self.loadUsers()
                // stop animate
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                
            }
            
        })
    }
    
    
    
    @objc func sumUpdateRecived(){
        
        loadUsers()
        
    }
    
    func loadUsers() {
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.users = []
        db.collection("users").getDocuments { querySnapshot, error in
            if let e = error {
                print("Error getting documents: \(e)")
                
            } else {
                if let documents = querySnapshot?.documents {
                    
                    for document in documents {
                        
                        let data = document.data()
                        
                        if let name = data["name"] as? String, let sum = data["sum"] as? Int {
                            
                            if document.data()["constant_amount_to_add"] != nil && document.data()["add_every"] != nil && document.data()["date_to_begin"] != nil{
                                
                                // Calculate how often to add money
                                let constantAmountToAdd = document.data()["constant_amount_to_add"] as? Int ?? 0
                                let addEvery = document.data()["add_every"] as? Int ?? 0
                                //                                let oldSum = sum ?? 0
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
                                                
                                                
                                                // grab from db the cell color & picture
                                                if document.data()["cellColor"] as? String != nil {
                                                    let colorHexString = document.data()["cellColor"] as! String
                                                    self.cellColor = UIColor(hexString: "\(colorHexString)")
                                                    
                                                    print("=====================")
                                                    print("cell color \(colorHexString)")
                                                    print("cell color \(self.cellColor)")
                                                    
                                                    if document.data()["pictureURL"] as? String != "" {
                                                        let imageURL = document.data()["pictureURL"] as? String
                                                        let storage = Storage.storage().reference(forURL: imageURL!)
                                                        storage.getData(maxSize: 5 * 1024 * 1024) { data, error in
                                                            if let error = error {
                                                                self.userImage = UIImage(named: "userIcon")!
                                                                print(error.localizedDescription)
                                                                
                                                                let newUser = User(name: name, sum: sum, cellColor: self.cellColor, picture: self.userImage)
                                                                
                                                                self.users.append(newUser)
                                                                self.tableView.reloadData()
                                                                
                                                                // stop animate
                                                                self.activityIndicator.stopAnimating()
                                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                            } else {
                                                                let colorHexString = document.data()["cellColor"] as! String
                                                                self.cellColor = UIColor(hexString: "\(colorHexString)")
                                                                
                                                                self.userImage = UIImage(data: data!)!
                                                                
                                                                let newUser = User(name: name, sum: sum, cellColor: self.cellColor, picture: self.userImage)
                                                                
                                                                self.users.append(newUser)
                                                                self.tableView.reloadData()
                                                                
                                                                // stop animate
                                                                self.activityIndicator.stopAnimating()
                                                                UIApplication.shared.endIgnoringInteractionEvents()
                                                            }
                                                        }
                                                        
                                                    }else{
                                                        self.userImage = UIImage(named: "userIcon")!
                                                        
                                                        let newUser = User(name: name, sum: sum, cellColor: self.cellColor, picture: self.userImage)
                                                        
                                                        self.users.append(newUser)
                                                        self.tableView.reloadData()
                                                        
                                                        // stop animate
                                                        self.activityIndicator.stopAnimating()
                                                        UIApplication.shared.endIgnoringInteractionEvents()
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
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToAddUserVC", sender: self)
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home") as? Home
            {
                self.present(vc, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
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
        cell.color.backgroundColor = users[indexPath.row].cellColor
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

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
