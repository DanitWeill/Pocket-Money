//
//  UserDetailsVC.swift
//  Pocket Money
//
//  Created by Danit on 03/02/2022.
//

import UIKit
import Firebase

class UserDetailsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    
    let db = Firestore.firestore()
    var arrayOfDate: [String] = []
    var arrayOfAmount: [Int] = []
    var dateArray: [DateAmount] = []
    var numOfCells = 0
    
    var usersStringToPass: [User] = []
    var userIndex = 0
    
    let addMoneyToUserVC = AddMoneyToUserVC()
    
    //    var dateArray: [DateAmount] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        importData()
        
        nameLabel.text = usersStringToPass[userIndex].name
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserDetailsCell", bundle: nil), forCellReuseIdentifier: "UserDetailsCellIdentifier")
        
        
        db.collection("users").document(usersStringToPass[userIndex].name).getDocument { doc, err in
            if let err = err{
                print(err.localizedDescription)
            }else{
                
                if doc?.data()?["sum"] != nil{
                    let data = doc?.data()?["sum"] as? Int
                    self.sumLabel.text = String(data ?? 0)
                }
                
            }
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("sumUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dateRecived), name: Notification.Name("dateUpdate"), object: nil)
        
    }
    
    
    func importData(){
        

        
        db.collection("users").document(usersStringToPass[userIndex].name).collection("history").order(by: "date").getDocuments { docs, err in
            if let e = err{
                print(e)
            } else {
                
                self.arrayOfDate = []
                self.arrayOfAmount = []
            
                if docs?.count ?? 0 > 0{
                    for i in 0...docs!.count-1{
                        
                        let date = docs?.documents[i]["date money added"] as? String
                        let amount = docs?.documents[i]["amount to add"] as? Int
                        
                        self.arrayOfDate.append(date ?? "")
                        self.arrayOfAmount.append(amount ?? 0)
                        
                    }
                }
                self.arrayOfDate.reverse()
                self.arrayOfAmount.reverse()
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    @objc func sumUpdateRecived(){
        db.collection("users").document(usersStringToPass[userIndex].name).getDocument { doc, err in
            if let err = err{
                print(err.localizedDescription)
            }else{
                
                if doc?.data()?["sum"] != nil{
                    let data = doc?.data()?["sum"] as? Int
                    self.sumLabel.text = String(data ?? 0)
                }
                
            }
        }
    }
    
    @objc func dateRecived(){
        importData()
    }
    
    @IBAction func goToaddMoneyPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "GoToAddMoneyToUserVC", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addMoneyToUserVC = segue.destination as? AddMoneyToUserVC {
            addMoneyToUserVC.nameToPass = nameLabel.text!
            addMoneyToUserVC.sumToPass = sumLabel.text!
            
        }
    }
}

extension UserDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDate.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsCellIdentifier", for: indexPath) as! UserDetailsCell
        
//        cell.dateLabel.text = dateArray[indexPath.row].dateMoneyAdded
//        cell.amountAddedLabel.text = String(dateArray[indexPath.row].amountAdded)
//        print(dateArray)
        
        
                cell.dateLabel.text = arrayOfDate[indexPath.row]
                cell.amountAddedLabel.text = String(arrayOfAmount[indexPath.row])
        
        return cell
    }
    
}
