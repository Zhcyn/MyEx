import UIKit
class AddExpenseViewController: UITableViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var notesField: UITextView!
    var item: Expense?
    fileprivate let coreDataManager = CoreDataManager(modelName: "MyTracker")
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = item{
            nameField.text = item.title
            amountField.text = String(item.amount)
            categoryField.text = item.category
            notesField.text = item.notes
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @IBAction func cancelAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        guard let title = nameField.text else {
            print("title not entered")
            self.showAlert(msg: "Enter title")
            return
        }
        guard let amount = amountField.text else {
            print("amount not entered")
            self.showAlert(msg: "Enter amount")
            return
        }
        guard let category = categoryField.text else {
            print("category not entered")
            self.showAlert(msg: "Enter category")
            return
        }
        if (title.isEmpty) ||
            (amount.isEmpty) ||
            (category.isEmpty) {
            self.showAlert(msg: "Enter required fields")
            return
        }
        if let expItem = item{
            expItem.title = title
            expItem.amount = Double(amount)!
            expItem.category = category
            expItem.notes = notesField.text
            expItem.createdAt = NSDate() as Date
        }else{
            let item  = Expense(context: coreDataManager.managedObjectContext)
            item.title = title
            item.amount = Double(amount)!
            item.category = category
            item.notes = notesField.text
            item.createdAt = NSDate() as Date
            do{
                try item.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print("Unable to save item")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    @IBAction func selectAction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let categoryViewController = storyBoard.instantiateViewController(withIdentifier: "CategoryViewController") as! CategoryExpenseViewController
        categoryViewController.delegate = self
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
    func showAlert(msg:String){
        let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension AddExpenseViewController: CategoryViewDelegate
{
    func didSelect(category:String){
        self.categoryField.text = category
    }
}
