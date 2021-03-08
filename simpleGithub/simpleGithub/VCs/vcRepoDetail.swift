//
//  vcUserInfo.swift
//  simpleGithub
//
//  Created by hasan milli on 7.03.2021.
//
//This page is going to show detail of repository (Repo Name , Owner username, Avatar email, fork count, Language, default branch name etc.
//When user clicks avatar, User Detail should be shown.
//
//

import UIKit

class vcRepoDetail: UIViewController {
    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lblRepoDetail: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblForkCount: UILabel!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblBranch: UILabel!
    @IBOutlet weak var lblWatchers: UILabel!
    @IBOutlet weak var lblSubscribers: UILabel!
    
    private var VC_UserInfo:vcUserInfo!
    
    private var dicUserData:Dictionary<String, Any> = [:]
    private var dicData:Dictionary<String, Any> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func actBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Getting Data from endpoint of github user detail and repo detail dictionary comes from previous page (main repo list page)
    func getData( strUserName:String, dicRepoDetail:Dictionary<String,Any> ) {
        startLoading()
        
        //get Repo Detail Data
        dicData = dicRepoDetail

        // Get User Info Data
        getDataWithStrUrl("https://api.github.com/users/" + strUserName, completionHandler: { (data, response, error) in
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
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    
                    if let dicResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        self.dicUserData = dicResult
                        DispatchQueue.main.async {
                            self.lblRepoDetail.text = self.dicData["name"] as? String
                            self.lblUserName.text = self.dicUserData["login"] as? String
                            self.lblEmail.text = self.dicUserData["email"] as? String
                            self.lblForkCount.text = String(self.dicData["forks"] as? Int ?? 0)
                            self.lblLanguage.text = self.dicData["language"] as? String
                            self.lblBranch.text = self.dicData["default_branch"] as? String
                            self.lblWatchers.text = String(self.dicData["watchers"] as? Int ?? 0)
                            self.lblSubscribers.text = String(self.dicUserData["followers"] as? Int ?? 0)
                            
                            self.btnAvatar.loadImageWithUrlStr((self.dicUserData["avatar_url"] as? String ?? ""))
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
    }
    
    //Click on profile picture and go for user details
    @IBAction func actGoUserInfo(_ sender: Any) {
        VC_UserInfo = self.storyboard?.instantiateViewController(withIdentifier: "vcUserInfo") as? vcUserInfo
        
        VC_UserInfo.getData(strUserName: (dicUserData["login"] as? String ?? ""), strUrl: (dicUserData["repos_url"] as? String ?? ""))
        
        VC_UserInfo.modalPresentationStyle = .fullScreen
        VC_UserInfo.modalTransitionStyle = .crossDissolve
        
        self.present(VC_UserInfo, animated: true, completion: nil)
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
