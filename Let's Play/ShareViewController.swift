//
//  ShareViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 12/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var gameName:String?
    var userName:String?
    var searchValue:String?
    var userDetailArray = [Result]()
    var filterUserArray = [Result]()
    var isSearching = false
    var frndName:String?
    var gName:String?


    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting the Search Bar
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userDetailArray = []
        tableView.delegate = self
        tableView.dataSource = self
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/search.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: gameName!))&search=\(String(describing: searchValue!))"
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
                    if let userDetails = json?.value(forKey: "results") as? NSArray {
                        for userDetail in userDetails{
                            if let userDetailDict = userDetail as? NSDictionary {
                                let result = Result(game: "", in_game_name: "", is_friend: false, name: "", username: "")
                                if let user = userDetailDict.value(forKey: "in_game_name"){
                                    result.in_game_name = user as! String
                                }
                                if let user = userDetailDict.value(forKey: "name"){
                                    result.name = user as! String
                                }
                                if let user = userDetailDict.value(forKey: "username"){
                                    result.username = user as! String
                                }
                                if let game = userDetailDict.value(forKey: "game"){
                                    result.game = game as! String
                                }
                                if let isf = userDetailDict.value(forKey: "is_friend"){
                                    result.is_friend = isf as! Bool
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
        return 100
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell") as! ShareViewCell
        if (isSearching){
            cell.gameIcon.image = UIImage(named: Constants.gameReverseDict[filterUserArray[indexPath.row].game]!)
            cell.friendUserName.text = filterUserArray[indexPath.row].username
            cell.f_inGameName.text = filterUserArray[indexPath.row].in_game_name
            cell.friendName.text = filterUserArray[indexPath.row].name
            cell.Add.isHidden = filterUserArray[indexPath.row].is_friend
        }
        else{
            cell.gameIcon.image = UIImage(named: Constants.gameReverseDict[userDetailArray[indexPath.row].game]!)
            cell.friendUserName.text = userDetailArray[indexPath.row].username
            cell.f_inGameName.text = userDetailArray[indexPath.row].in_game_name
            cell.friendName.text = userDetailArray[indexPath.row].name
            cell.Add.isHidden = userDetailArray[indexPath.row].is_friend
        }
        cell.Add.tag = indexPath.row
        cell.Add.addTarget(self, action:#selector(add(sender:)), for: .touchUpInside)
        cell.layer.cornerRadius = cell.frame.height/2
        return cell
    }
    
    @IBAction func add(sender : UIButton){
        let index = sender.tag
        if (isSearching){
            frndName = filterUserArray[index].username
            gName = filterUserArray[index].game
        }
        else{
            frndName = userDetailArray[index].username
            gName = userDetailArray[index].game
        }
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/addfriend.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: gName!))&f_username=\(String(describing: frndName!))"
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
                        return
                    })
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    class Result{
        var game: String
        var in_game_name:String
        var is_friend:Bool
        var name:String
        var username:String
        init(game:String,in_game_name:String,is_friend:Bool,name:String,username:String) {
            self.game = game
            self.in_game_name = in_game_name
            self.is_friend = is_friend
            self.name = name
            self.username = username
        }
    }
}
