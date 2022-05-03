//
//  UserDetailsVC.swift
//  Pocket Money
//
//  Created by Danit on 03/02/2022.
//

import UIKit
import Firebase
import SwiftUI

class UserDetailsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var addMoneyPicker: UIButton!
    
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
        
        addMoneyPicker.frame = CGRect(x: 160, y: 100, width: 70, height: 70)
        addMoneyPicker.layer.cornerRadius = 0.5 * addMoneyPicker.bounds.size.width
        addMoneyPicker.clipsToBounds = true
          view.addSubview(addMoneyPicker)
        
//        userPicture.layer.cornerRadius = 100
        userPicture.clipsToBounds = true
        importData()
        
        nameLabel.text = usersStringToPass[userIndex].name
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserDetailsCell", bundle: nil), forCellReuseIdentifier: "UserDetailsCellIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(sumUpdateRecived), name: Notification.Name("sumUpdate"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dateRecived), name: Notification.Name("dateUpdate"), object: nil)
        
    }
    
    
    func importData(){
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
        
        db.collection("users").document(usersStringToPass[userIndex].name).getDocument { doc, error in
            if let error = error{
                print(error.localizedDescription)
            }else{
                let userPicRef = doc?.data()?["pictureURL"] as? String
                if userPicRef != "" {
                let storage = Storage.storage().reference(forURL: userPicRef!)
                storage.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        self.userPicture.image = UIImage(named: "userIcon")!
                        print(error.localizedDescription)
                    } else {
                        self.userPicture.image = UIImage(data: data!)!
                        }
                    }
                } else {
                    self.userPicture.image = UIImage(named: "userIcon")!
                }
            }
        }
        
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
    
    

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let popUpButtonsVC = segue.destination as? PopUpButtonsVC {
            popUpButtonsVC.nameToPass = nameLabel.text!
            
        }
    }
}



extension UserDetailsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDate.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsCellIdentifier", for: indexPath) as! UserDetailsCell
        
        cell.backgroundColor = UIColor(#colorLiteral(red: 1, green: 0.8856521249, blue: 0.1325125396, alpha: 1))
        
        cell.dateLabel.text = arrayOfDate[indexPath.row]
        cell.amountAddedLabel.text = String(arrayOfAmount[indexPath.row])
        
        return cell
    }
    
}
