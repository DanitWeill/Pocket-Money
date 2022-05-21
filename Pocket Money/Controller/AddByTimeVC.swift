//
//  AddByTimeVC.swift
//  Pocket Money
//
//  Created by Danit on 22/02/2022.
//

import UIKit
import Firebase

class AddByTimeVC: UIViewController {
    
    
    
    @IBOutlet weak var constantAmountToAddTextfield: UITextField!
    @IBOutlet weak var swicher: UISwitch!
    
    
    @IBOutlet weak var sunButton: UIButton!
    @IBOutlet weak var monButton: UIButton!
    @IBOutlet weak var tueButton: UIButton!
    @IBOutlet weak var wedButton: UIButton!
    @IBOutlet weak var thuButton: UIButton!
    @IBOutlet weak var friButton: UIButton!
    @IBOutlet weak var satButton: UIButton!
    
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    
    
    
    let db = Firestore.firestore()
    var dateToBeginString = String()
    var dateToBeginDate = Date()
    var addEvery = 0
    var finalAmountToAdd = 0
    
    var nameToPass: String = ""
    var currentWeekday: Int = 1
    var daysToAdd = 0
    let addOneDay = Date.now.addingTimeInterval(86400)
    let addTwoDays = Date.now.addingTimeInterval(172800)
    let addTreeDays = Date.now.addingTimeInterval(259200)
    let addFourDays = Date.now.addingTimeInterval(345600)
    let addFiveDays = Date.now.addingTimeInterval(432000)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
    
    }
    
    @objc func tap(sender: UITapGestureRecognizer){
        print("tapped")
        view.endEditing(true)
    }
    
    func setConstantAmountToAdd(){
        guard let uid = Auth.auth().currentUser?.uid else {return}

        db.collection("families").document(uid).collection("kids").document(nameToPass).updateData([
            "constant_amount_to_add": Int(constantAmountToAddTextfield.text ?? "0")])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
                //what will happen if the name and sum are nil
            } else {
                print("setConstantAmountToAdd successfully written!")
                print(self.constantAmountToAddTextfield.text)
            }
            
        }
        
    }
    
    func setDateToBegin(){
        
        let date = Date()
        let calendar = Calendar.current
        currentWeekday = calendar.component(.weekday, from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy  at  HH:mm"
        
        
        dateToBeginDate = date.addingTimeInterval(TimeInterval(daysToAdd * 86400))
        dateToBeginString = formatter.string(from: dateToBeginDate)
        let dayToBegin = calendar.component(.weekday, from: dateToBeginDate)
        
        guard let uid = Auth.auth().currentUser?.uid else {return}

        db.collection("families").document(uid).collection("kids").document(nameToPass).updateData([
            "day_to_begin": dayToBegin, "date_to_begin": date.timeIntervalSince1970 + TimeInterval(daysToAdd * 86400)])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
                //what will happen if the name and sum are nil
            } else {
                print("setDateToBegin successfully written!")
                
            }
        }
        
    }
    
    
    
    func setAddEvery() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}

        db.collection("families").document(uid).collection("kids").document(nameToPass).updateData([
            "add_every": addEvery])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
                //what will happen if the name and sum are nil
            } else {
                print("setAddEvery successfully written!")
                
            }
        }
    }
    
    
    @IBAction func sunButton(_ sender: UIButton) {
        if sunButton.isSelected == false {
            sunButton.isSelected = true
            sunButton.backgroundColor = UIColor.gray
            
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            
            if currentWeekday > 1 {
                daysToAdd = (7 - currentWeekday) + 1
            }else if currentWeekday < 1{
                daysToAdd = 1 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func monButton(_ sender: UIButton) {
        if monButton.isSelected == false {
            monButton.isSelected = true
            monButton.backgroundColor = UIColor.gray
            
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            
            if currentWeekday > 2 {
                daysToAdd = (7 - currentWeekday) + 2
            }else if currentWeekday < 2{
                daysToAdd = 2 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func tueButton(_ sender: UIButton) {
        if tueButton.isSelected == false {
            tueButton.isSelected = true
            tueButton.backgroundColor = UIColor.gray
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            if currentWeekday > 3 {
                daysToAdd = (7 - currentWeekday) + 3
            }else if currentWeekday < 3{
                daysToAdd = 3 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func wedButton(_ sender: UIButton) {
        if wedButton.isSelected == false {
            wedButton.isSelected = true
            wedButton.backgroundColor = UIColor.gray
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            if currentWeekday > 4 {
                daysToAdd = (7 - currentWeekday) + 4
            }else if currentWeekday < 4{
                daysToAdd = 4 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func thuButton(_ sender: UIButton) {
        if thuButton.isSelected == false {
            thuButton.isSelected = true
            thuButton.backgroundColor = UIColor.gray
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            
            if currentWeekday > 5 {
                daysToAdd = (7 - currentWeekday) + 5
            }else if currentWeekday < 5{
                daysToAdd = 5 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func friButton(_ sender: UIButton) {
        if friButton.isSelected == false {
            friButton.isSelected = true
            friButton.backgroundColor = UIColor.gray
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            satButton.isSelected = false
            satButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            
            if currentWeekday > 6 {
                daysToAdd = (7 - currentWeekday) + 6
            }else if currentWeekday < 6{
                daysToAdd = 6 - currentWeekday
            }else{
                daysToAdd = 0
            }
        }
    }
    
    @IBAction func satButton(_ sender: UIButton) {
        if satButton.isSelected == false {
            satButton.isSelected = true
            satButton.backgroundColor = UIColor.gray
            sunButton.isSelected = false
            sunButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monButton.isSelected = false
            monButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            tueButton.isSelected = false
            tueButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            wedButton.isSelected = false
            wedButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            thuButton.isSelected = false
            thuButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            friButton.isSelected = false
            friButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            
            if currentWeekday > 7 {
                daysToAdd = (7 - currentWeekday) + 7
            }else if currentWeekday < 7{
                daysToAdd = 7 - currentWeekday
            }else{
                daysToAdd = 0
            }
            
        }
    }
    
    
    @IBAction func dayButton(_ sender: UIButton) {
        if dayButton.isSelected == false {
            dayButton.isSelected = true
            dayButton.backgroundColor = UIColor.gray
            
            //            add 86400 (sec in 1 day)
            //            let addOneDay = dateToBeginDate.addingTimeInterval(86400)
            
            let addOneDay = dateToBeginDate.addingTimeInterval(86400)
            
            
            print(addOneDay)
            print("================")
            
            
            weekButton.isSelected = false
            weekButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monthButton.isSelected = false
            monthButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            yearButton.isSelected = false
            yearButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            addEvery = 1
        }
    }
    
    @IBAction func weekButton(_ sender: UIButton) {
        if weekButton.isSelected == false {
            weekButton.isSelected = true
            weekButton.backgroundColor = UIColor.gray
            dayButton.isSelected = false
            dayButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monthButton.isSelected = false
            monthButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            yearButton.isSelected = false
            yearButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            addEvery = 7
            
        }
    }
    
    @IBAction func monthButton(_ sender: UIButton) {
        if monthButton.isSelected == false {
            monthButton.isSelected = true
            monthButton.backgroundColor = UIColor.gray
            dayButton.isSelected = false
            dayButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            weekButton.isSelected = false
            weekButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            yearButton.isSelected = false
            yearButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            addEvery = 30
            
        }
    }
    
    @IBAction func yearButton(_ sender: UIButton) {
        if yearButton.isSelected == false {
            yearButton.isSelected = true
            yearButton.backgroundColor = UIColor.gray
            dayButton.isSelected = false
            dayButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            weekButton.isSelected = false
            weekButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            monthButton.isSelected = false
            monthButton.backgroundColor = #colorLiteral(red: 1, green: 0.656021297, blue: 0.1703382134, alpha: 1)
            
            addEvery = 365
            
        }
    }
    
    
    
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        
        if swicher.isOn{
            setConstantAmountToAdd()
            setDateToBegin()
            setAddEvery()
            
        } else {
            //do nothing
        }
        
        
        
        showToast(message: "Saved!", font: .systemFont(ofSize: 12.0))
        
    }
    
}



extension AddByTimeVC {
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }
