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
    var nickNameArray = [String]()
    var platformArray = [String]()
    var nickArray = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gameArray = []
        nickNameArray = []
        platformArray = []
        nickArray = []
        
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
                
                let status = jsonObj!["status"] as! String
                let message = jsonObj!["message"] as! String
                if (status == "s")
                {
                    if let gameDetails = jsonObj!.value(forKey: "games") as? NSArray {
                        for gameDetail in gameDetails{
                            if let gameDetailDict = gameDetail as? NSDictionary {
                                if let game = gameDetailDict.value(forKey: "game"){
                                    let Game = Constants.gameReverseDict[game as! String]
                                    self.gameArray.append(Game!)
                                }
                                if let nickName = gameDetailDict.value(forKey: "nickname"){
                                    self.nickNameArray.append(nickName as! String)
                                }
                                if let platform = gameDetailDict.value(forKey: "platform"){
                                    self.platformArray.append(platform as! String)
                                }
                                if let nick = gameDetailDict.value(forKey: "in_game_name"){
                                    self.nickArray.append(nick as! String)
                                }
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                }
                if (status == "e"){
                    DispatchQueue.main.async(execute:{
                        let myAlert = UIAlertController(title: " ", message: "\(message)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            print("Alert: \(message)")
                        }
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion:nil)
                    })
                    return
                }
            }
            catch let error as NSError{
                print("Failed to load : \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return gameArray.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameListCell
        cell.game.text = gameArray[indexPath.row]
        cell.nickname.text = nickArray[indexPath.row]
        cell.layer.cornerRadius = cell.frame.height/2
        cell.share.tag = indexPath.row
        cell.share.addTarget(self, action:#selector(Share(sender:)), for: .touchUpInside)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let statsController = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
        statsController?.gamePass = gameArray[indexPath.row]
        statsController?.nickNamePass = nickNameArray[indexPath.row]
        statsController?.platformPass = platformArray[indexPath.row]
        statsController?.nickPass = nickArray[indexPath.row]
        self.navigationController?.pushViewController(statsController!, animated: true)
    }
    
    @IBAction func Share(sender : UIButton){
        let index = sender.tag
        let shareController = storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as? ShareViewController
        let usrname = UserDefaults.standard.string(forKey: "username") as String!
        shareController?.userName = usrname
        shareController?.gameName = gameArray[index]
        shareController?.searchValue = "%"
        self.navigationController?.pushViewController(shareController!, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



