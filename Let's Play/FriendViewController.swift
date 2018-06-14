//
//  FriendViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 13/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchValue:String?
    var userName:String?
    var userDetailArray = [Result]()
    var filterUserArray = [Result]()
    var isSearching = false
    var frndName:String?
    var gameName:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        friendLoad()
    }
    
    func friendLoad(){
        userDetailArray = []
        tableView.delegate = self
        tableView.dataSource = self
        userName = UserDefaults.standard.string(forKey: "username") as String!
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/getfriendslist.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: userName!))"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            print("postString = \(String(describing: postString))")
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do
            {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? NSDictionary
                print("JSON Data : \(String(describing: json))")
                let status = (json!["status"] as? String)!
                let message = (json!["message"] as? String)!
                if (status == "s")
                {
                    if let userDetails = json?.value(forKey: "friends") as? NSArray {
                        for userDetail in userDetails{
                            if let userDetailDict = userDetail as? NSDictionary {
                                let result = Result(game: "", name: "", username: "", nickname: "", platform: "")
                                if let user = userDetailDict.value(forKey: "name"){
                                    result.name = user as! String
                                }
                                if let username = userDetailDict.value(forKey: "username"){
                                    result.username = username as! String
                                }
                                if let game = userDetailDict.value(forKey: "game"){
                                    result.game = game as! String
                                }
                                if let nickname = userDetailDict.value(forKey: "nickname"){
                                    result.nickname = nickname as! String
                                }
                                if let platform = userDetailDict.value(forKey: "platform"){
                                    result.platform = platform as! String
                                }
                                self.userDetailArray.append(result)
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                    print(self.userDetailArray)
                }
                if (status == "e"){
                    DispatchQueue.main.async(execute:{
                        let myAlert = UIAlertController(title: " ", message: "\(message)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            print("Error")
                        }
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion:nil)
                        return
                    })
                }
            }
            catch let error as NSError{
                print("Failed to load : \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (isSearching){
            return filterUserArray.count
        }
        else {
            return userDetailArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendViewCell
        if (isSearching){
            cell.gameIcon.image = UIImage(named: Constants.gameReverseDict[filterUserArray[indexPath.row].game]!)
            cell.f_userName.text = filterUserArray[indexPath.row].username
            cell.friendName.text = filterUserArray[indexPath.row].name
        }
        else{
            cell.gameIcon.image = UIImage(named: Constants.gameReverseDict[userDetailArray[indexPath.row].game]!)
            cell.f_userName.text = userDetailArray[indexPath.row].username
            cell.friendName.text = userDetailArray[indexPath.row].name
        }
        cell.layer.cornerRadius = cell.frame.height/2
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let statsController = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
        if (isSearching){
            statsController?.gamePass = filterUserArray[indexPath.row].game
            statsController?.uname = filterUserArray[indexPath.row].username
            statsController?.nickNamePass = filterUserArray[indexPath.row].nickname
            statsController?.platformPass = filterUserArray[indexPath.row].platform
        }
        else{
            statsController?.gamePass = userDetailArray[indexPath.row].game
            statsController?.uname = userDetailArray[indexPath.row].username
            statsController?.nickNamePass = userDetailArray[indexPath.row].nickname
            statsController?.platformPass = userDetailArray[indexPath.row].platform
        }
        
        self.navigationController?.pushViewController(statsController!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            if (isSearching){
                frndName = filterUserArray[indexPath.row].username
                gameName = filterUserArray[indexPath.row].game
            }
            else{
                frndName = userDetailArray[indexPath.row].username
                gameName = userDetailArray[indexPath.row].game
            }
            let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/removefriend.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = "username=\(String(describing: userName!))&game=\(String(describing: gameName!))&f_username=\(String(describing: frndName!))"
            print("Post String: \(postString)")
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(String(describing: responseString))")
                print("postString = \(String(describing: postString))")
                let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                do
                {
                    let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? NSDictionary
                    print("JSON Data : \(String(describing: json))")
                    let status = (json!["status"] as? String)!
                    let message = (json!["message"] as? String)!
                    if (status == "s")
                    {
                        DispatchQueue.main.async(execute:{
                            let myAlert = UIAlertController(title: " ", message: "\(message)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            }
                            myAlert.addAction(okAction)
                            self.present(myAlert, animated: true, completion:nil)
                            self.friendLoad()
                            return
                        })
                        
                    }
                    if (status == "e"){
                        DispatchQueue.main.async(execute:{
                            let myAlert = UIAlertController(title: "Alert", message: "\(message)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            }
                            myAlert.addAction(okAction)
                            self.present(myAlert, animated: true, completion:nil)
                            return
                        })
                    }
                }
                catch let error as NSError{
                    print("Failed to load : \(error.localizedDescription)")
                }
            }
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Function for filtering the table view cells based on what the user types in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if ((searchBar.text == nil)||(searchBar.text == "")){
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        }
        else
        {
            isSearching = true
            filterUserArray = userDetailArray.filter({$0.name.contains(searchBar.text!)})
            tableView.reloadData()
        }
    }

    class Result{
        var game: String
        var name:String
        var username:String
        var nickname:String
        var platform:String
        init(game:String,name:String,username:String,nickname:String,platform:String) {
            self.game = game
            self.name = name
            self.username = username
            self.nickname = nickname
            self.platform = platform
        }
    }

}
