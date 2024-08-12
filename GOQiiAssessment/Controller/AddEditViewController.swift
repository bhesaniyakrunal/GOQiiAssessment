//
//  AddEditViewController.swift
//  GOQiiAssessment
//
//  Created by MacBook on 8/12/24.
//

import UIKit
import CoreData
protocol UpdataViewProtcol {
    func updateData()
}

class AddEditViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var measurementSegmentedControl: UISegmentedControl!
    @IBOutlet weak var buttonSave: UIButton!
    
    var updataView:UpdataViewProtcol? = nil
    var waterLog: WaterLog?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let log = waterLog {
            amountTextField.text = String(log.amount)
            measurementSegmentedControl.selectedSegmentIndex = log.measure == "ML" ? 0 : 1
            self.titleLabel.text = "Updated Details"
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = waterLog {
            self.title = "Update Details"
        }
        self.title = "Add Details"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
        self.updataView?.updateData()
        
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let amountText = amountTextField.text, let amount = Int16(amountText) else {
            return
        }
        let measurementIndex = measurementSegmentedControl.selectedSegmentIndex
        let measurement = measurementIndex == 0 ? "ML" : "OZ"
        
        if let log = waterLog {
            log.amount = Int16(amount)
            log.measure = measurement
            log.date = Date() 
            DatabaseHelper.shared.saveContext()
            showUpdateConfirmation()
        } else {
            DatabaseHelper.shared.saveWaterLog(amount: amount, measure: measurement)
            showSaveConfirmation()
        }
    }
    func showSaveConfirmation() {
        let alert = UIAlertController(title: "Success", message: "Water intake logged successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showUpdateConfirmation() {
        let alert = UIAlertController(title: "Success", message: "Water log updated successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
}
