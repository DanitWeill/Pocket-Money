//
//  AddByTimeVC.swift
//  Pocket Money
//
//  Created by Danit on 22/02/2022.
//

import UIKit

class AddByTimeVC: UIViewController {
    
    

    @IBOutlet weak var amountTextfield: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var repeatPicker: UIPickerView!
    
    
    let reapetEvery = ["every day", "every week", "every month", "every year"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        repeatPicker.delegate = self
        repeatPicker.dataSource = self
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {

        
    }
    
}

extension AddByTimeVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
       return reapetEvery.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
            return reapetEvery[row]
    }
    
   
    
}
