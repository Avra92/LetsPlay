//
//  HomeViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 10/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var resultArray = [Result]()
    var uname: String?
    var usrname: String?
    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        usrname = UserDefaults.standard.string(forKey: "username") as String!
        activityIndicator = UIActivityIndicatorView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gameListLoad()
    }

    func gameListLoad() {
        showOrHideActivityIndicator(show: true)
        resultArray = []

        tableView.delegate = self
        tableView.dataSource = self
        uname = UserDefaults.standard.string(forKey: "username") as String!

        let postString = "username=\(String(describing: uname!))"
        let request = Constants.createRequest(url: Constants.gamesListURL, postString: postString)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                self.showOrHideActivityIndicator(show: false)
            })

            guard let data = data, error == nil else {
                self.showError(message: Constants.error_internet)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { self.showError(message: Constants.error_server)
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: Data!, options: .allowFragments) as? NSDictionary

                let status = jsonObj!["status"] as! String
                let message = jsonObj!["message"] as! String
                if (status == "s") {
                    if let gameDetails = jsonObj!.value(forKey: "games") as? NSArray {
                        for gameDetail in gameDetails {
                            if let gameDetailDict = gameDetail as? NSDictionary {
                                var result = Result(game: "", nickname: "", platform: "", in_game_name: "")
                                if let game = gameDetailDict.value(forKey: "game") {
                                    result.game = game as! String
                                }
                                if let nickName = gameDetailDict.value(forKey: "nickname") {
                                    result.nickname = nickName as! String
                                }
                                if let platform = gameDetailDict.value(forKey: "platform") {
                                    result.platform = platform as! String
                                }
                                if let nick = gameDetailDict.value(forKey: "in_game_name") {
                                    result.in_game_name = nick as! String
                                }
                                self.resultArray.append(result)
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    } else {
                        self.showError(message: Constants.error_general)
                    }
                } else {
                    self.showError(message: message)
                }
            } catch _ as NSError {
                self.showError(message: Constants.error_general)
            }
        }
        task.resume()
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

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count

    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameListCell
        cell.lbl_game.text = Constants.gameReverseDict[resultArray[indexPath.row].game]
        cell.lbl_nickname.text = resultArray[indexPath.row].in_game_name
        cell.view_container.layer.cornerRadius = 10
        cell.view_container.layer.borderWidth = 2
        cell.view_container.layer.borderColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor.clear
        cell.btn_addFriends.tag = indexPath.row
        cell.btn_addFriends.addTarget(self, action: #selector(didTapAddFriends(sender:)), for: .touchUpInside)
        cell.btn_letsPlay.tag = indexPath.row
        cell.btn_letsPlay.addTarget(self, action: #selector(didTapLetsPlay(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let game = resultArray[indexPath.row].game
            let nickname = resultArray[indexPath.row].nickname
            let platform = resultArray[indexPath.row].platform

            let alert = UIAlertController(title: "Delete game", message: "Are you sure you want to delete this game?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                self.deleteGame(game: game, nickname: nickname, platform: platform)
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) { action in
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func deleteGame(game: String, nickname: String, platform: String) {
        showOrHideActivityIndicator(show: true)
        let postString = "username=\(String(describing: uname!))&game=\(String(describing: game))&nickname=\(String(describing: nickname))&platform=\(platform)"
        let request = Constants.createRequest(url: Constants.removeGameURL, postString: postString)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                self.showOrHideActivityIndicator(show: false)
            })

            guard let data = data, error == nil else {
                self.showError(message: Constants.error_internet)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { self.showError(message: Constants.error_server)
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
                        self.gameListLoad()
                    } else {
                        self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
                    }
                })
            } catch _ as NSError {
                self.showError(message: Constants.error_general)
            }
        }
        task.resume()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let statsController = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
        statsController?.uname = usrname
        statsController?.gamePass = resultArray[indexPath.row].game
        statsController?.nickNamePass = resultArray[indexPath.row].nickname
        statsController?.platformPass = resultArray[indexPath.row].platform
        self.navigationController?.pushViewController(statsController!, animated: true)
    }

    @IBAction func didTapAddFriends(sender: UIButton) {
        let index = sender.tag
        let shareController = storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as? ShareViewController
        shareController?.userName = usrname
        shareController?.gameName = resultArray[index].game
        shareController?.searchValue = "%"
        self.navigationController?.pushViewController(shareController!, animated: true)
    }

    @IBAction func didTapLetsPlay(sender: UIButton) {
        showOrHideActivityIndicator(show: true)
        let index = sender.tag

        let usrname = UserDefaults.standard.string(forKey: "username") as String!
        let game = resultArray[index].game

        let postString = "username=\(String(describing: usrname!))&game=\(String(describing: game))"
        let request = Constants.createRequest(url: Constants.letsPlayURL, postString: postString)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                self.showOrHideActivityIndicator(show: false)
            })
            guard let data = data, error == nil else {
                self.showError(message: Constants.error_internet)
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { self.showError(message: Constants.error_server)
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any]
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
            }
        }
        task.resume()

    }


    @IBAction func didTapAddGame(_ sender: Any) {
        let addGameController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        self.navigationController?.pushViewController(addGameController!, animated: true)
    }

    @IBAction func didTapFriendsList(_ sender: UIButton) {
        let friendController = storyboard?.instantiateViewController(withIdentifier: "FriendViewController") as? FriendViewController
        self.navigationController?.pushViewController(friendController!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    struct Result {
        var game: String
        var nickname: String
        var platform: String
        var in_game_name: String
    }
}



