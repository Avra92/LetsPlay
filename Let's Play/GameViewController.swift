//
//  GameViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 9/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class GameViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {

    @IBOutlet weak var game: UITextField!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var gameId: UITextField!
    @IBOutlet weak var platform: UITextField!
    @IBOutlet weak var infoText: UITextView!
    var selectedField = 0
    var statArray = [String]()
    var statValueArray = [String]()
    
    // Creating Game List
    let gameList =     [ "Counter Strike: Global Offensive","Fortnite","PlayerUnknown's Battlegrounds","Clash of Clans","Clash Royale","Dota 2","League of Legends"]
    var gameMenu     = UIPickerView()
    
    // Creating Platform List
    let platformList =     [ "Android","iOS","PC","PS4","Xbox"]
    var platformMenu     = UIPickerView()
    
    let csgoList =     [ "Custom URL ID","Steam 64 ID"]
    var csgoMenu     = UIPickerView()
    
    let fortniteList = ["PC","PS4","Xbox"]
    var fortniteMenu = UIPickerView()
    
    let cocList = ["Android","iOS"]
    var cocMenu = UIPickerView()
    
    
    let pubgList = ["Xbox - Asia", "Xbox - Europe", "Xbox - North America", "Xbox - Oceania", "PC - Korea", "PC - Japan", "PC - North America", "PC - Europe", "PC - Russia", "PC - Oceania", "PC - Kakao", "PC - South East Asia", "PC - South and Central America", "PC - Asia"]
    var pubgMenu = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setting up the Picker View List for Games and Platforms
        gameMenu.dataSource = self
        gameMenu.delegate = self
        gameMenu.backgroundColor = UIColor.gray
        game.inputView = gameMenu
        game.placeholder = "Select Game you want to add"
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func GameSelect(_ sender: Any) {
        let field = sender as! UITextField
        selectedField = field.tag
        platform.text = " "
    }
    
    @IBAction func PlatformSelect(_ sender: Any) {
        let field = sender as! UITextField
        selectedField = field.tag
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        // Checking Text Field Tags, tag = 1 means Game is selected
        if (selectedField == 1)
        {
            return gameList.count
        }
        else
        {
            if (game.text == "Counter Strike: Global Offensive")
            {
                return csgoList.count
            }
            else if (game.text == "PlayerUnknown's Battlegrounds")
            {
                return pubgList.count
            }
            else if (game.text == "Fortnite")
            {
                return fortniteList.count
            }
            else{
                return cocList.count
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if (selectedField == 1)
        {
            return gameList[row]
        }
        else
        {
            
            if (game.text == "Counter Strike: Global Offensive")
            {
                return csgoList[row]
            }
            else if (game.text == "PlayerUnknown's Battlegrounds")
            {
                return pubgList[row]
            }
            else if (game.text == "Fortnite")
            {
                return fortniteList[row]
            }
            else{
                return cocList[row]
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedField == 1)
        {
            game.text = gameList[row]
            game.resignFirstResponder()
            if (game.text?.isEmpty == false)
            {
                if (game.text == "Counter Strike: Global Offensive")
                {
                    infoText.text = Constants.infoDict["csdotaInfo"]
                    csgoMenu.dataSource = self
                    csgoMenu.delegate = self
                    csgoMenu.backgroundColor = UIColor.gray
                    platform.inputView = csgoMenu
                    platform.placeholder = "Select the type of ID you are using"
                }
                if (game.text == "PlayerUnknown's Battlegrounds")
                {
                    pubgMenu.dataSource = self
                    pubgMenu.delegate = self
                    pubgMenu.backgroundColor = UIColor.gray
                    platform.inputView = pubgMenu
                    platform.placeholder = "Select the Platform and appropriate Region"
                }
                if (game.text == "Fortnite")
                {
                    fortniteMenu.dataSource = self
                    fortniteMenu.delegate = self
                    fortniteMenu.backgroundColor = UIColor.gray
                    platform.inputView = fortniteMenu
                    platform.placeholder = "Select the Platform"
                }
                if ((game.text == "Clash of Clans") || (game.text == "Clash Royale"))
                {
                    infoText.text = Constants.infoDict["coccrInfo"]
                    cocMenu.dataSource = self
                    cocMenu.delegate = self
                    cocMenu.backgroundColor = UIColor.gray
                    platform.inputView = cocMenu
                    platform.placeholder = "Select the Platform"
                }
            }
        }
        else
        {
            if (game.text == "Counter Strike: Global Offensive")
            {
                platform.text = csgoList[row]
                platform.resignFirstResponder()
            }
            else if (game.text == "PlayerUnknown's Battlegrounds")
            {
                platform.text = pubgList[row]
                platform.resignFirstResponder()
            }
            else if (game.text == "Fortnite")
            {
                platform.text = fortniteList[row]
                platform.resignFirstResponder()
            }
            else{
                platform.text = cocList[row]
                platform.resignFirstResponder()
            }
        }
    }
    
    @IBAction func addGame(_ sender: UIButton) {
        let Game = game.text
        let GameId = gameId.text
        let Platform = platform.text
        statArray = []
        statValueArray = []
        
        let uname = UserDefaults.standard.string(forKey: "username") as String!
        
        if ((Game?.isEmpty)! || (GameId?.isEmpty)! || (Platform?.isEmpty)!) {
            let alert = UIAlertController(title: " ", message: "Please fill all the fields", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction!) -> Void in
                print("Ok")
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion:nil)
            return
        }
        else {
            let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/addgame.php")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = "username=\(String(describing: uname!))&game=\(String(describing: Constants.gameDict[Game!]!))&nickname=\(String(describing: GameId!))&platform=\(String(describing: Constants.platDict[Platform!]!))"
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
