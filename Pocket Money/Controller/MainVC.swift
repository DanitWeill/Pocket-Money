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
   
    let db = Firestore.firestore()
    
    var userIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    
        
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCellIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("newUserUpdate"), object: nil)
        
        loadUsers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("sumUpdate"), object: nil)
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
                if let snapShotDocuments = querySnapshot?.documents {
                    for document in snapShotDocuments {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        if let name = data["name"] as? String, let sum = data["sum"] as? Int {
                            let newUser = User(name: name, sum: sum)
                            self.users.append(newUser)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
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
