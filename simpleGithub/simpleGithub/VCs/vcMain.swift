//
//  ViewController.swift
//  simpleGithub
//
//  Created by hasan milli on 7.03.2021.
//
// Search Repositories Page
// This page should able to search along public repositories on github.
// Results should be shown in tableView on this page.
// Cells should contain avatar (or gravatar) of owner , and username and repo’s name
// When user clicks avatar, application should open User Detail Page.
// When user clicks anywhere except image, Repository Detail page should be shown.
// Page Should have ability to paginate.
//
//
//

import UIKit

class vcMain: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tblResults: UITableView!
    
    private var arrData:[Dictionary<String, Any>] = []
    
    private var pageNo = 1
    private var maxItemCount = 100
    
    private var sectionCount = 2
    
    private var VC_UserInfo:vcUserInfo!
    private var VC_RepoDetail:vcRepoDetail!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData(true) //getting all Repositories data
    }
    
    //Getting Data from endpoint of github repo list
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
                        self.maxItemCount = (dicResult["total_count"] as? Int) ?? self.maxItemCount
                        DispatchQueue.main.async {
                            self.arrData.append(contentsOf: dicResult["items"] as? Array ?? [])
                            if(self.maxItemCount == self.arrData.count) {
                                self.sectionCount = 1
                            }
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
    
    //Table Cell Button item click handle
    @IBAction func actItemClicked(_ sender: Any) {
        let lBtn = sender as! UIButton
        
        VC_UserInfo = self.storyboard?.instantiateViewController(withIdentifier: "vcUserInfo") as? vcUserInfo
        
        //getting user id and sending to user info vc (to get user info)
        let dicData = self.arrData[lBtn.tag]
        let dicUsr = dicData["owner"] as? Dictionary<String, Any>
        VC_UserInfo.getData(strUserName: (dicUsr?["login"] as? String ?? ""), strUrl: (dicUsr?["repos_url"] as? String ?? ""))
        
        VC_UserInfo.modalPresentationStyle = .fullScreen
        VC_UserInfo.modalTransitionStyle = .crossDissolve
        
        self.present(VC_UserInfo, animated: true, completion: nil)
    }
    
    //------------- TABLE VIEW -------------
    var isLoading = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY + scrollView.frame.height) > contentHeight && !isLoading {
            if((pageNo + 1)*100 <= (maxItemCount - 100) ) {
                pageNo = pageNo + 1
                getData()
                
            } else {
                self.isLoading = false
                sectionCount = 1
                tblResults.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
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
            
            cell.btnAvatar.setImage(UIImage.init(named: "usrImg"), for: .normal)

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
        VC_RepoDetail = self.storyboard?.instantiateViewController(withIdentifier: "vcRepoDetail") as? vcRepoDetail
        
        //getting user repo url and sending to repo detail vc (to get user repos)
        let dicData = self.arrData[indexPath.row]
        let dicUsr = dicData["owner"] as? Dictionary<String, Any>
        VC_RepoDetail.getData(strUserName: (dicUsr?["login"] as? String ?? ""), dicRepoDetail: dicData)
        
        VC_RepoDetail.modalPresentationStyle = .fullScreen
        VC_RepoDetail.modalTransitionStyle = .crossDissolve
        
        self.present(VC_RepoDetail, animated: true, completion: nil)
    }
}

