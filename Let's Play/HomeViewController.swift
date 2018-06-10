//
//  HomeViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var gameArray = [String]()
    var nickArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let uname = UserDefaults.standard.string(forKey: "username") as String!
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/getgameslist.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: uname!))"
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
                let jsonObj = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as? NSDictionary
                
                if let gameDetails = jsonObj!.value(forKey: "games") as? NSArray {
                    for gameDetail in gameDetails{
                        if let gameDetailDict = gameDetail as? NSDictionary {
                            if let game = gameDetailDict.value(forKey: "game"){
                                let Game = Constants.gameReverseDict[game as! String]
                                self.gameArray.append(Game!)
                                print(self.gameArray)
                            }
                            if let nick = gameDetailDict.value(forKey: "nickname2"){
                                self.nickArray.append(nick as! String)
                                print(self.nickArray)
                            }
                            OperationQueue.main.addOperation({
                                self.tableView.reloadData()
                            })
                        }
                    }
                }
            }
            catch let error as NSError{
                print("Failed to load : \(error.localizedDescription)")
            }
        }
        task.resume()
        // Do any additional setup after loading the view.
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return gameArray.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameListCell
        cell.game.text = gameArray[indexPath.row]
        cell.nickname.text = nickArray[indexPath.row]
        cell.layer.cornerRadius = cell.frame.height/2
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


