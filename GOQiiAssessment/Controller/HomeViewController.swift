//
//  HomeViewController.swift
//  GOQiiAssessment
//
//  Created by MacBook on 8/12/24.
//

import UIKit
import CoreData
class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var waterLogs: [WaterLog] = []
    var dailyIntake: [Date: Double] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadDailyIntake()
        self.tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        let barButtonAdd =  UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(barAdd(sender:)))
        self.navigationItem.rightBarButtonItem = barButtonAdd
        let barButtonRemind = UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(barReminder(sender:)))
        self.navigationItem.leftBarButtonItem = barButtonRemind
        
        NotificationManager.shared.scheduleDailyHydrationReminder(hour: 9, minute: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Home"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }

    func loadDailyIntake() {
        dailyIntake = DatabaseHelper.shared.fetchDailyWaterIntake()
        tableView.reloadData()
    }
    
    @objc func barReminder(sender: UIBarButtonItem) {
        let selectedHour = 9
        let selectedMinute = 0
        NotificationManager.shared.removeScheduledNotifications()
        NotificationManager.shared.scheduleDailyHydrationReminder(hour: selectedHour, minute: selectedMinute)
    }
    @objc func barAdd(sender: UIBarButtonItem) {
        let addEdit = Config.StoryBoard.instantiateViewController(withIdentifier: "AddEditViewController") as! AddEditViewController
        addEdit.updataView = self
        self.navigationController?.pushViewController(addEdit, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dailyIntake.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(dailyIntake.keys)[section]
        let fetchRequest: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [date, Calendar.current.date(byAdding: .day, value: 1, to: date)!])
        do {
            return  try DatabaseHelper.shared.context.fetch(fetchRequest).count
        } catch {
            print("Failed to fetch logs for edit: \(error)")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        let date = Array(dailyIntake.keys)[indexPath.section]
        if let totalIntake = dailyIntake[date] {
            let fetchRequest: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [date, Calendar.current.date(byAdding: .day, value: 1, to: date)!])
            do {
                let logs = try DatabaseHelper.shared.context.fetch(fetchRequest)[indexPath.row].amount
                let measure = try DatabaseHelper.shared.context.fetch(fetchRequest)[indexPath.row].measure
                cell.amountLabel?.text = "Total Intake: \(logs) \(measure ?? "")"
            } catch {
                print("Failed to fetch logs for edit: \(error)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = Array(dailyIntake.keys)[indexPath.section]
        let fetchRequest: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [date, Calendar.current.date(byAdding: .day, value: 1, to: date)!])
        
        do {
            let logs = try DatabaseHelper.shared.context.fetch(fetchRequest)
                if let editVC = Config.StoryBoard.instantiateViewController(withIdentifier: "AddEditViewController") as? AddEditViewController {
                    editVC.waterLog = logs[indexPath.row]
                    editVC.updataView = self
                    navigationController?.pushViewController(editVC, animated: true)
                }
        } catch {
            print("Failed to fetch logs for edit: \(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Array(dailyIntake.keys)[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else { return }
        let date = Array(dailyIntake.keys)[indexPath.section]
        let fetchRequest: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", argumentArray: [date, Calendar.current.date(byAdding: .day, value: 1, to: date)!])
        do {
            let logs = try DatabaseHelper.shared.context.fetch(fetchRequest)
            if let log = logs.first {
                if logs.count == 1 {
                    dailyIntake.removeValue(forKey: date)
                }
                DatabaseHelper.shared.deleteWaterLog(log: log)
            }
        } catch {
            print("Failed to fetch logs for edit: \(error)")
        }
        self.loadDailyIntake()
    }
}

extension HomeViewController : UpdataViewProtcol {
    func updateData() {
        self.tableView.reloadData()
        self.loadDailyIntake()
    }
}
