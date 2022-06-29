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
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var kids: [Kid] = []
    
    let date = Date()
    var timesToAdd = 0
    
    
    var name = String()
    var sum = Float()
    var currencyName = String()
    var cellColor = UIColor(hexString: "#ffffff")
    var kidImage = UIImage()
    
    var kidsIndex = Int()
    
    //    let baseCoinURL = "https://rest.coinapi.io/v1/exchangerate/ILS"
    //    let apiKey = "75EF3C24-E5DB-4CCC-BA28-47B9DC49B408"
    var rate = Float()
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton.menu = addMenuItems()
        
        updateDefaultCurreny()
        
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
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRecived), name: Notification.Name("newUserUpdate"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRecived), name: Notification.Name("sumUpdate"), object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.updateRecived), name: Notification.Name("currencyNameUpdate"), object: nil)
                
                
                
                
                self.loadKids()
                // stop animate
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                
            }
            
        })
    }
    
    
    
    @objc func updateRecived(){
        updateDefaultCurreny()
        loadKids()
        
    }
    
    func loadKids() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        //loading circle
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.kids = []
        
        
        self.db.collection("families").document(uid).getDocument { doc, error in
            if let err = error{
                print(err.localizedDescription)
            }else{
                let currency = doc?.data()?["currency"] ?? "ILS"
                
                FetchCurrencyManager().fetchCoin(currencyName: currency as! String) { rateRecived in
                    print("rate recived \(rateRecived)")
                    self.rate = rateRecived
                    print("=============== rate \(self.rate)")
                    
                    self.db.collection("families").document(uid).collection("kids").getDocuments { querySnapshot, error in
                        if let e = error {
                            print("Error getting documents: \(e)")
                            
                        } else {
                            if let documents = querySnapshot?.documents {
                                
                                for document in documents {
                                    
                                    let data = document.data()
                                    
                                    if let name = data["name"] as? String, let sum = data["sum"] as! Float * self.rate as? Float {
                                        self.name = name
                                        self.sum = sum
                                        
                                        //                                    let constantAmountToAdd = document.data()["constant_amount_to_add"] as? Int ?? 0
                                        //                                    let addEvery = document.data()["add_every"] as? Int ?? 0
                                        //                                    let dateToBegin = document.data()["date_to_begin"] as! TimeInterval
                                        //
                                        //                                    Task {
                                        //                                            do {
                                        //                                                try await DateCalculate().dateCalculate(nameOfKid: name, constantAmountToAdd: constantAmountToAdd, addEvery: addEvery, dateToBegin: dateToBegin)
                                        //                                            } catch {
                                        //                                               print(error)
                                        //                                            }
                                        //                                         }
                                        
                                        
                                        
                                        
                                        // grab from db the cell color & picture
                                        if document.data()["cellColor"] as? String != nil {
                                            let colorHexString = document.data()["cellColor"] as! String
                                            self.cellColor = UIColor(hexString: "\(colorHexString)")
                                            
                                            
                                            if document.data()["pictureURL"] as? String != "" {
                                                let imageURL = document.data()["pictureURL"] as? String
                                                let storage = Storage.storage().reference(forURL: imageURL!)
                                                storage.getData(maxSize: 5 * 1024 * 1024) { data, error in
                                                    if let error = error {
                                                        self.kidImage = UIImage(named: "userIcon")!
                                                        print(error.localizedDescription)
                                                        
                                                        
                                                        let newUser = Kid(name: name, sum: sum.rounded(), cellColor: self.cellColor, picture: self.kidImage)
                                                        
                                                        self.kids.append(newUser)
                                                        self.tableView.reloadData()
                                                        
                                                        // stop animate
                                                        self.activityIndicator.stopAnimating()
                                                        UIApplication.shared.endIgnoringInteractionEvents()
                                                    } else {
                                                        let colorHexString = document.data()["cellColor"] as! String
                                                        self.cellColor = UIColor(hexString: "\(colorHexString)")
                                                        
                                                        self.kidImage = UIImage(data: data!)!
                                                        
                                                        let newUser = Kid(name: name, sum: sum.rounded(), cellColor: self.cellColor, picture: self.kidImage)
                                                        
                                                        self.kids.append(newUser)
                                                        self.tableView.reloadData()
                                                        
                                                        // stop animate
                                                        self.activityIndicator.stopAnimating()
                                                        UIApplication.shared.endIgnoringInteractionEvents()
                                                    }
                                                }
                                                
                                            }else{
                                                self.kidImage = UIImage(named: "userIcon")!
                                                
                                                let newUser = Kid(name: name, sum: sum.rounded(), cellColor: self.cellColor, picture: self.kidImage)
                                                
                                                self.kids.append(newUser)
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
    
//    @objc func announceSumUpdate(){
//
//    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToAddUserVC", sender: self)
        
    }
    
    
    func addMenuItems() -> UIMenu{
        let menuItems = UIMenu(title: "Menu", image: UIImage(systemName: "text.justify"), options: .displayInline, children: [
            UIAction(title: "Currency", handler: { (_) in
                self.performSegue(withIdentifier: "goToCurrency", sender: self)
            }),
            
            UIAction(title: "Sign Out", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive, handler: { (_) in
                print("Sign Out")
                self.signOut()
                
            })
            
        ])
        return menuItems
    }
    
    
    func signOut(){
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
    
    func updateDefaultCurreny(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        db.collection("families").document(uid).getDocument(completion: { document, error in
            if let error = error {
                print(error)
                self.db.collection("families").document(uid).setData([
                    "currency": "ILS"
                ])
                self.currencyName = "ILS"
            }
            
            if document?.exists ?? false {
                print("exist")
                self.currencyName = document?.data()?["currency"] as! String
            } else {
                print("not exist")
                self.db.collection("families").document(uid).setData([
                    "currency": "ILS"
                ])
                self.currencyName = "ILS"
            }
            
            print("=======================")
            print(self.currencyName)
        })
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userDetailsVC = segue.destination as? UserDetailsVC {
            userDetailsVC.kidsStringToPass = kids
            userDetailsVC.kidsIndex = kidsIndex
            userDetailsVC.currencyNameToPass = currencyName
//            userDetailsVC.currencySumToPass = sum
            userDetailsVC.rateToPass = rate
            print(kids)
        }
        if let addUserVC = segue.destination as? AddUserVC {
            addUserVC.rateToPass = rate
        }
        
    }
    
}


extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kids.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCellIdentifier", for: indexPath) as! UserCell
        
        cell.delegate = self
        
        cell.nameLabel.text = kids[indexPath.row].name
        cell.sumLabel.text = String(kids[indexPath.row].sum)
        //        String(Float(kids[indexPath.row].sum) * self.rate)
        cell.color.backgroundColor = kids[indexPath.row].cellColor
        cell.userPicture.image = kids[indexPath.row].picture
        cell.currencyLabel.text = currencyName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kidsIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        performSegue(withIdentifier: "goToUserDetailsVC", sender: self)
//        NotificationCenter.default.addObserver(self, selector: #selector(announceSumUpdate), name: Notification.Name("announceSumUpdate"), object: nil)
    }
    
    
    
    
    
}

extension MainVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("item deleted")
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            self.db.collection("families").document(uid).collection("kids").document(self.kids[indexPath.row].name).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.kids = []
            self.loadKids()
            tableView.reloadData()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
}

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
