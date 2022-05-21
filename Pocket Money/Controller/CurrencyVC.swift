//
//  CurrencyVC.swift
//  Pocket Money
//
//  Created by Danit on 08/05/2022.
//

import UIKit
import Firebase

class CurrencyVC: UIViewController {
    
    @IBOutlet weak var currencyTableView: UITableView!
    
    let baseCoinURL = "https://rest.coinapi.io/v1/exchangerate/ILS"
    let apiKey = "75EF3C24-E5DB-4CCC-BA28-47B9DC49B408"
    var currencyName = "ILS"
    var rate = Float()
    var rateToPass = Float()
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        
    }
    
    
    func updatedCurrencyNameInDB(){
  
        guard let uid = Auth.auth().currentUser?.uid else {return}

        db.collection("families").document(uid).setData([
            "currency": currencyName
        ])
      
            NotificationCenter.default.post(name: Notification.Name("currencyNameUpdate"), object: nil)
    }
}


extension CurrencyVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: "currencyCell", for: indexPath)
        cell.textLabel?.text = currencyArray[indexPath.row]
        cell.textLabel?.textAlignment =  .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //define the current currency for all amounts in all VCs
        currencyName = currencyArray[indexPath.row]
        print(currencyName)
        updatedCurrencyNameInDB()
        
        NotificationCenter.default.post(name: Notification.Name("dateUpdate"), object: nil)
        
        
        dismiss(animated: true, completion: nil)
    }
    
}

