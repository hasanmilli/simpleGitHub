//
//  ViewController.swift
//  simpleGithub
//
//  Created by hasan milli on 7.03.2021.
//

import UIKit

class vcMain: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tblResults: UITableView!
    
    private var vwLoading = UIView()
    private var indVwLoading = UIActivityIndicatorView()
    
    private var arrData:[Dictionary<String, Any>] = []
    
    private var pageNo = 1
    private var maxItemCount = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getting all Repositories data
        getData(true)
    }
    /*
    func startLoading() {
        DispatchQueue.main.async { //running it in main queue if needed in threads
            self.vwLoading.frame = CGRect.init(x: -50, y: -50, width: self.view.bounds.size.width+100, height: self.view.bounds.size.height + 100)
            self.vwLoading.backgroundColor = UIColor.init(white: 0, alpha: 0.5)

            self.indVwLoading.center = self.vwLoading.center

            self.view.addSubview(self.vwLoading)
            self.view.addSubview(self.indVwLoading)
            
            self.indVwLoading.startAnimating()
        }
    }

    func stopLoading() {
        DispatchQueue.main.async { //running it in main queue if needed in threads
            self.indVwLoading.stopAnimating()
            self.indVwLoading.removeFromSuperview()
            self.vwLoading.removeFromSuperview()
        }
    }*/
    
    func showAlert(_ strHeader:String, strDetail:String)  {
        let alert = UIAlertController(title: strHeader, message: strDetail, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
              switch action.style{
              case .default:
                break

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")


              @unknown default:
                fatalError()
              }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getData(_ flushCurrData:Bool = false) {
        let url = URL(string: "https://api.github.com/search/repositories?q=retrofit&per_page=100&page=" + String(pageNo))!
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        
        //startLoading()
        self.isLoading = true
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            //self.stopLoading()
            
            if flushCurrData {
                self.arrData.removeAll()
            }
            
            guard error == nil else {
                self.showAlert("Error", strDetail: error?.localizedDescription ?? "Connection Error!")
                return
            }

            guard let data = data else {
                self.showAlert("Error", strDetail: "Invalid data!")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    
                    if let dicResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        self.maxItemCount = (dicResult["total_count"] as? Int) ?? 100
                        DispatchQueue.main.async {
                            self.arrData.append(contentsOf: dicResult["items"] as? Array ?? [])
                            self.tblResults.reloadData()
                            self.isLoading = false
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })

        task.resume()
    }
    
    @IBAction func actItemClicked(_ sender: Any) {
        let lBtn = sender as! UIButton
        
        print(arrData[lBtn.tag])
    }
    
    //------------- TABLE VIEW -------------
    var isLoading = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 4) && !isLoading {
            if((pageNo + 1)*100 <= (maxItemCount - 100) ) {
                pageNo = pageNo + 1
                getData()
                
            } else {
                showAlert("", strDetail: "No more data.")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrData.count //Return items counts
            
        } else { // section == 1
            return 1 //Return the Loading cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell:tbcell_Item = tableView.dequeueReusableCell(withIdentifier: "tbcell_Item") as! tbcell_Item

            if (indexPath.row < arrData.count) {
                let dicData = self.arrData[indexPath.row]
                let dicUsr = dicData["owner"] as? Dictionary<String, Any>
                
                cell.lblUserName.text = dicUsr?["login"] as? String
                cell.lblRepoName.text = dicData["name"] as? String
                cell.btnAvatar.loadImageWithUrlStr((dicUsr?["avatar_url"] as? String ?? ""))
                cell.btnAvatar.tag = indexPath.row
                cell.btnAvatar.addTarget(self, action: #selector(self.actItemClicked), for: .touchUpInside)
            }

            return cell
            
        } else {
            let cell:tbcell_loading = tableView.dequeueReusableCell(withIdentifier: "tbcell_loading") as! tbcell_loading
            cell.indVwLoading.startAnimating()
            
            return cell
        }
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dicData = self.arrData[indexPath.row]
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}

