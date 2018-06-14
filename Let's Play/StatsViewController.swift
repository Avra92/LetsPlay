//
//  StatsViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 11/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var gameIcon: UIImageView!
    @IBOutlet weak var gameNick: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var gamePass:String?
    var nickNamePass:String?
    var platformPass:String?
    var uname:String?
    
    var statDetailArray = [String]()
    var statValueArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.delegate = self
        tableView.dataSource = self
        gameIcon.image = UIImage(named: Constants.gameReverseDict[gamePass!]!)
        statDetailArray = []
        statValueArray = []
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/getgamestats.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        print(gamePass!)
        print(nickNamePass!)
        print(platformPass!)
        print(uname!)
        let postString = "username=\(String(describing: uname!))&game=\(String(describing: gamePass!))&nickname=\(String(describing: nickNamePass!))&platform=\(String(describing: platformPass!))"
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
                    if let statDetails = json?.value(forKey: "stats") as? NSArray {
                        for statDetail in statDetails{
                            if let statDetailDict = statDetail as? NSDictionary {
                                if let stat = statDetailDict.value(forKey: "key"){
                                    self.statDetailArray.append(stat as! String)
                                }
                                if let statValue = statDetailDict.value(forKey: "value"){
                                    self.statValueArray.append(statValue as! String)
                                }
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                    if let inGameNick = json?.value(forKey: "in_game_name") as? String {
                        DispatchQueue.main.async(execute:{
                             self.gameNick.text = inGameNick
                        })
                    }
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
        return statDetailArray.count
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell") as! StatViewCell
        cell.statDetail.text = statDetailArray[indexPath.row]
        cell.statValue.text = statValueArray[indexPath.row]
        return cell
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
