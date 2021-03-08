//
//  vcUserInfo.swift
//  simpleGithub
//
//  Created by hasan milli on 7.03.2021.
//
// This page should show the owner details of clicked repository.
// Page should show some basic user information like email,username,avatar etc.
// Page should show show repositories of user.
// Page should have ability to paginate
// This page should contain one tableView which contains 2 types of cell. First is
// userData, others are repository cells.
//
//


import UIKit

class vcUserInfo: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tblResults: UITableView!
    
    private var VC_RepoDetail:vcRepoDetail!
    
    private var dicUserData:Dictionary<String, Any> = [:]
    private var arrData:[Dictionary<String, Any>] = []
    
    private var pageNo = 1
    private var willLoadMore = true
    
    private var sectionCount = 3
    
    private var strURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Getting Data from endpoint of github user detail and call user repo list get function
    func getData( strUserName:String, strUrl:String ) {
        startLoading()

        // Get User Info Data
        getDataWithStrUrl("https://api.github.com/users/" + strUserName, completionHandler: { (data, response, error) in
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
                        DispatchQueue.main.async {
                            self.dicUserData = dicResult
                            self.tblResults.reloadData()
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        getUserRepoData(strUrl)
    }
    
    //Getting Data from endpoint of github repos of the user
    func getUserRepoData(_ strUrl:String = "") {
        if(strUrl.count > 0) {
            strURL = strUrl
        }
        
        self.isLoading = true
        
        //get Repo Detail Data
        getDataWithStrUrl(strURL + "?per_page=50&page=" + String(pageNo), completionHandler: { (data, response, error) in
            self.stopLoading()
            
            guard error == nil else {
                self.showAlert("Error", strDetail: error?.localizedDescription ?? "Connection Error!")
                return
            }

            guard let data = data else {
                self.showAlert("Error", strDetail: "Invalid data!")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: Any]] {
                    print(json)
                    
                    if let arrResult = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] {
                        DispatchQueue.main.async {
                            self.arrData.append(contentsOf: arrResult)
                            
                            if(arrResult.count < 50) {
                                self.sectionCount = 2
                                self.willLoadMore = false
                            }
                            
                            self.tblResults.reloadData()
                            self.isLoading = false
                        }
                    }
                }
            } catch let err {
                print(err.localizedDescription)
            }
        })
    }

    //------------- TABLE VIEW -------------
    var isLoading = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if ((offsetY + scrollView.frame.height) > contentHeight && !isLoading) {
            if(willLoadMore) {
                pageNo = pageNo + 1
                getUserRepoData()
                
            } else {
                self.isLoading = false
                //showAlert("", strDetail: "No more data.")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { //user Info
            if(dicUserData.count > 0) {
                return 1
            } else {
                return 0
            }
            
        } else if section == 1 {
            return arrData.count //Return items counts
            
        } else { //Return the Loading cell
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { //user Info
            return 150
            
        } else if indexPath.section == 1 {
            return 64
            
        } else { //Return the Loading cell
            return 64
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { //user Info
            let cell:tbcell_UserItem = tableView.dequeueReusableCell(withIdentifier: "tbcell_UserItem") as! tbcell_UserItem

            if dicUserData.count > 0 {
                cell.lblUserName.text = (dicUserData["login"] as? String ?? "") + " - " + (dicUserData["name"] as? String ?? "")
                cell.lblEmail.text = dicUserData["email"] as? String
                cell.lblPublic_repos.text = String(dicUserData["public_repos"] as? Int ?? 0)
                cell.lblFollowersCount.text = String(dicUserData["followers"] as? Int ?? 0)
                cell.btnAvatar.loadImageWithUrlStr((dicUserData["avatar_url"] as? String ?? ""))
                cell.btnAvatar.isUserInteractionEnabled = false
            }
            return cell
            
        } else if indexPath.section == 1 {
            let cell:tbcell_UserRepoItem = tableView.dequeueReusableCell(withIdentifier: "tbcell_UserRepoItem") as! tbcell_UserRepoItem

            if (indexPath.row < arrData.count) {
                let dicData = self.arrData[indexPath.row]

                cell.lblRepoName.text = dicData["name"] as? String
                cell.lblWatchersCount.text = "Watchers Count: " + String(dicData["watchers"] as? Int ?? 0)
            }

            return cell
            
        } else { //Return the Loading cell
            let cell:tbcell_loading = tableView.dequeueReusableCell(withIdentifier: "tbcell_loading") as! tbcell_loading
            cell.indVwLoading.startAnimating()
            
            return cell
        }
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if indexPath.section == 0 { //user Info
            
        } else if indexPath.section == 1 {
            
            VC_RepoDetail = self.storyboard?.instantiateViewController(withIdentifier: "vcRepoDetail") as? vcRepoDetail
            
            //getting user repo url and sending to repo detail vc (to get user repos)
            let dicData = self.arrData[indexPath.row]
            let dicUsr = dicData["owner"] as? Dictionary<String, Any>
            VC_RepoDetail.getData(strUserName: (dicUsr?["login"] as? String ?? ""), dicRepoDetail: dicData)
            
            VC_RepoDetail.modalPresentationStyle = .fullScreen
            VC_RepoDetail.modalTransitionStyle = .crossDissolve
            
            self.present(VC_RepoDetail, animated: true, completion: nil)
            VC_RepoDetail.btnAvatar.isUserInteractionEnabled = false
            
        } else { //Return the Loading cell
        }
    }
    
    private var vwLoading = UIView()
    private var indVwLoading = UIActivityIndicatorView()
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
    }
}
