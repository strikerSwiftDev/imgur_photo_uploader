

import UIKit
import SafariServices


class UrlsViewController: UIViewController {
    
    var links = DataManager.shared.detLinks()
    
    @IBOutlet weak var urlsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlsTableView.delegate = self
        urlsTableView.dataSource = self
        
        urlsTableView.tableFooterView = UIView()
        
    }
}


extension UrlsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = urlsTableView.dequeueReusableCell(withIdentifier: "UrlTabelViewCellIdentifier")!
        
        cell.textLabel?.text = links[indexPath.row].absoluteString
        
        return cell
        
    }
    
    
}

extension UrlsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let safariVC = SFSafariViewController(url: links[indexPath.row])
        present(safariVC, animated: true, completion: nil)
        
        
    }
    
    
}
