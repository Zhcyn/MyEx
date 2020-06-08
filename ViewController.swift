import UIKit
import CoreData
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate let coreDataManager = CoreDataManager(modelName: "MyTracker")
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Expense> = {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = NSSortDescriptor(key: "category", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: "category", cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save item")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func applicationDidEnterBackground(){
        showPasscodeLockScreen()
    }
    func showPasscodeLockScreen(){
        if (UserDefaults.standard.value(forKey: "PASSCODE") as? String) != nil {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let passcodeViewController = storyBoard.instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
            navigationController?.present(passcodeViewController, animated: true, completion: nil)
            passcodeViewController.messageLabel.text = "Enter passcode to view your expenses"
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "SegueAddExpenseViewController":
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard (navigationController.viewControllers.first as? AddExpenseViewController) != nil else { return }
        case "SegueExpenseViewController":
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let navigationController = segue.destination as? UINavigationController else { return }
            guard let viewController = navigationController.viewControllers.first as? AddExpenseViewController else { return }
            let expenseItem = fetchedResultsController.object(at: indexPath)
            viewController.item = expenseItem
        default:
            print("Unknown Segue")
        }
    }
    @IBAction func segmentChangedAction(_ sender: UISegmentedControl) {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        let dateFrom = calendar.startOfDay(for: Date()) 
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
        components.day! += 1
        let dateTo = calendar.date(from: components)! 
        switch sender.selectedSegmentIndex {
        case 0:
            self.fetchedResultsController.fetchRequest.predicate  = nil
        case 1:
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [dateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
        case 2:
            let newDateFromComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
            components.day! -= 7;
            let newDateFrom = calendar.date(from: newDateFromComponents)!
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [newDateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
        case 3:
            let newDateFromComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute],from: dateFrom)
            components.month! -= 1;
            let newDateFrom = calendar.date(from: newDateFromComponents)!
            let datePredicate = NSPredicate(format: "(%@ <= createdAt) AND (createdAt < %@)", argumentArray: [newDateFrom, dateTo])
            self.fetchedResultsController.fetchRequest.predicate  = datePredicate
        default:
            break;
        }
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save item")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
}
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
         return (fetchedResultsController.sections?.count)!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        configureCell(cell, at: indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController.sections else {
            return ""
        }
        let sectionInfo = sections[section]
        let header = sectionInfo.name
        var amount:Double=0.0
        for item in sectionInfo.objects! {
            amount += (item as! Expense).amount;
        }
        return "\(header) - (\(amount) ₹)";
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let item = fetchedResultsController.object(at: indexPath)
        fetchedResultsController.managedObjectContext.delete(item)
    }
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = String(item.amount)+" ₹"
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
