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
    var gameDetailArray = [String]()
    var userDetailArray = [String]()
    var filterUserArray = [String]()
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
        gameDetailArray = []
        tableView.delegate = self
        tableView.dataSource = self
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/search.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: Constants.gameDict[gameName!]!))&search=\(String(describing: searchValue!))"
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
                                if let user = userDetailDict.value(forKey: "name"){
                                    self.userDetailArray.append(user as! String)
                                }
                                if let game = userDetailDict.value(forKey: "game"){
                                    self.gameDetailArray.append(game as! String)
                                }
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                    print(self.userDetailArray)
                    print(self.gameDetailArray)
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
        return 70
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell") as! ShareViewCell
        cell.gameIcon.image = UIImage(named: Constants.gameReverseDict[gameDetailArray[indexPath.row]]!)
        if (isSearching){
            cell.friendName.text = filterUserArray[indexPath.row]
        }
        else{
            cell.friendName.text = userDetailArray[indexPath.row]
        }
        cell.Add.tag = indexPath.row
        cell.Add.addTarget(self, action:#selector(add(sender:)), for: .touchUpInside)
        cell.layer.cornerRadius = cell.frame.height/2
        return cell
    }
    
    @IBAction func add(sender : UIButton){
        let index = sender.tag
        if (isSearching){
            frndName = filterUserArray[index]
        }
        else{
            frndName = userDetailArray[index]
        }
        gName = gameDetailArray[index]
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
                            self.dismiss(animated: true,completion: nil)
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
            filterUserArray = userDetailArray.filter({$0.contains(searchBar.text!)})
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

}
