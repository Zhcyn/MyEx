import UIKit
protocol CategoryViewDelegate {
    func didSelect(category:String)
}
class CategoryExpenseViewController: UITableViewController {
    let categories = ["Food","Fuel","Shopping","Electronics",
                      "Subscriptions","Billpay","Travel",
                      "Automobiles","Sports"]
    var delegate:CategoryViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Categories"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else {
            return
        }
        delegate.didSelect(category: categories[indexPath.row])
        _ = navigationController?.popViewController(animated: true)
    }
}
