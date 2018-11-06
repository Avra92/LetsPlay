//
//  GameViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 9/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var txt_game: UITextField!
    @IBOutlet weak var txt_gameId: UITextField!
    @IBOutlet weak var txt_platform: UITextField!
    @IBOutlet weak var txt_infoText: UITextView!
    var selectedField = 0
    var statArray = [String]()
    var statValueArray = [String]()
    var activityIndicator: UIActivityIndicatorView?

    // Creating Game List
    let gameList = ["Counter Strike: Global Offensive", "Fortnite", "Clash of Clans", "Clash Royale"]
    var gameMenu = UIPickerView()

    // Creating Platform List
    let platformList = ["Android", "iOS", "PC", "PS4", "Xbox"]
    var platformMenu = UIPickerView()

    //Creating csgo platformlist
    let csgoList = ["Custom URL ID", "Steam 64 ID"]
    var csgoMenu = UIPickerView()

    //Creating Fortnite platformlist
    let fortniteList = ["PC", "PS4", "Xbox"]
    var fortniteMenu = UIPickerView()

    //Creating Clash of Clans and Clash Royale platformlist
    let cocList = ["Android", "iOS"]
    var cocMenu = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
        // Setting up the Picker View List for Games and Platforms
        gameMenu.dataSource = self
        gameMenu.delegate = self
        gameMenu.backgroundColor = UIColor.gray
        txt_game.inputView = gameMenu
        txt_game.placeholder = "Select Game you want to add"
    }

    func showError(message: String) {
        DispatchQueue.main.async(execute: {
            self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
        })
    }

    func showOrHideActivityIndicator(show: Bool) {
        if (show) {
            activityIndicator?.center = self.view.center
            activityIndicator?.hidesWhenStopped = true
            activityIndicator?.activityIndicatorViewStyle = .whiteLarge
            view.addSubview(activityIndicator!)
            UIApplication.shared.beginIgnoringInteractionEvents()
            activityIndicator?.startAnimating()
        } else {
            UIApplication.shared.endIgnoringInteractionEvents()
            activityIndicator?.stopAnimating()
        }
    }

    @IBAction func didTapGame(_ sender: Any) {
        let field = sender as! UITextField
        selectedField = field.tag
        txt_platform.text = ""
    }

    @IBAction func didTapPlatform(_ sender: Any) {
        let field = sender as! UITextField
        selectedField = field.tag
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1

    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Checking Text Field Tags, tag = 1 means Game is selected
        if (selectedField == 1) {
            return gameList.count
        } else {
            if (txt_game.text == "Counter Strike: Global Offensive") {
                return csgoList.count
            } else if (txt_game.text == "Fortnite") {
                return fortniteList.count
            } else {
                return cocList.count
            }
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (selectedField == 1) {
            return gameList[row]
        } else {
            if (txt_game.text == "Counter Strike: Global Offensive") {
                return csgoList[row]
            } else if (txt_game.text == "Fortnite") {
                return fortniteList[row]
            } else {
                return cocList[row]
            }
        }
    }

    //Based on the game selected in txt_game the picker list for txt_platform will change
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedField == 1) {
            txt_game.text = gameList[row]
            txt_game.resignFirstResponder()
            if (txt_game.text?.isEmpty == false) {
                if (txt_game.text == "Counter Strike: Global Offensive") {
                    txt_infoText.text = Constants.infoDict["csInfo"]
                    csgoMenu.dataSource = self
                    csgoMenu.delegate = self
                    csgoMenu.backgroundColor = UIColor.gray
                    txt_platform.inputView = csgoMenu
                    txt_platform.placeholder = "Select the type of ID you are using"
                }
                if (txt_game.text == "Fortnite") {
                    fortniteMenu.dataSource = self
                    fortniteMenu.delegate = self
                    fortniteMenu.backgroundColor = UIColor.gray
                    txt_platform.inputView = fortniteMenu
                    txt_platform.placeholder = "Select the Platform"
                }
                if ((txt_game.text == "Clash of Clans") || (txt_game.text == "Clash Royale")) {
                    txt_infoText.text = Constants.infoDict["coccrInfo"]
                    cocMenu.dataSource = self
                    cocMenu.delegate = self
                    cocMenu.backgroundColor = UIColor.gray
                    txt_platform.inputView = cocMenu
                    txt_platform.placeholder = "Select the Platform"
                }
            }
        } else {
            if (txt_game.text == "Counter Strike: Global Offensive") {
                txt_platform.text = csgoList[row]
            } else if (txt_game.text == "Fortnite") {
                txt_platform.text = fortniteList[row]
            } else {
                txt_platform.text = cocList[row]
            }
            txt_platform.resignFirstResponder()
        }
    }

    @IBAction func didTapAddGame(_ sender: UIButton) {
        let game = txt_game.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let gameId = txt_gameId.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let platform = txt_platform.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        statArray = []
        statValueArray = []

        let uname = UserDefaults.standard.string(forKey: "username") as String!
        
        //Checking if the user is trying to add games leaving some fields empty
        if (game!.isEmpty || gameId!.isEmpty || platform!.isEmpty) {
            self.present(Constants.createAlert(title: "Error", message: "Please fill all the fields"), animated: true, completion: nil)
        } else {
            showOrHideActivityIndicator(show: true)
            //Calling the addGame URL by passing the username, game name, nickname and the platform the user plays that game
            let postString = "username=\(String(describing: uname!))&game=\(String(describing: Constants.gameDict[game!]!))&nickname=\(String(describing: gameId!))&platform=\(String(describing: Constants.platDict[platform!]!))"
            let request = Constants.createRequest(url: Constants.addGameURL, postString: postString)

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async(execute: {
                    self.showOrHideActivityIndicator(show: false)
                })

                guard let data = data, error == nil else {
                    self.showError(message: Constants.error_internet)
                    return
                }

                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    self.showError(message: Constants.error_server)
                    return
                }

                let responseString = String(data: data, encoding: .utf8)
                let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                do {
                    let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? NSDictionary
                    let status = (json!["status"] as? String)!
                    let message = (json!["message"] as? String)!
                    DispatchQueue.main.async(execute: {
                        if (status == "s") {
                            self.present(Constants.createAlert(title: "Success", message: message), animated: true, completion: nil)
                        } else {
                            self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
                        }
                    })
                } catch _ as NSError {
                    self.showError(message: Constants.error_general)
                    return
                }
            }
            task.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
