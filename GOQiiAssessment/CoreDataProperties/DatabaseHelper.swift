import CoreData
import UIKit

class DatabaseHelper {
    
    static let shared = DatabaseHelper()
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func saveWaterLog(amount: Int16, measure: String) {
        let waterLog = WaterLog(context: context)
        waterLog.amount = Int16(amount)
        waterLog.measure = measure
        waterLog.date = Date()
        saveContext()
    }
    
    func fetchDailyWaterIntake() -> [Date: Double] {
            let fetchRequest: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
            let logs: [WaterLog]
            
            do {
                logs = try context.fetch(fetchRequest)
            } catch {
                print("Failed to fetch logs: \(error)")
                return [:]
            }

            var dailyIntake: [Date: Double] = [:]
            
            for log in logs {
                let date = Calendar.current.startOfDay(for: log.date ?? Date())
                let intake = Double(log.amount)
                dailyIntake[date, default: 0] += intake
            }
            
            return dailyIntake
        }

    
    func deleteWaterLog(log: WaterLog) {
        context.delete(log)
        saveContext()
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
