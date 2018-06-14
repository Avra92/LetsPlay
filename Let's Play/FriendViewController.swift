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

    var searchValue: String?
    var userName: String?
    var userDetailArray = [Result]()
    var filterUserArray = [Result]()
    var isSearching = false

    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        activityIndicator = UIActivityIndicatorView()
        friendLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func friendLoad() {
        showOrHideActivityIndicator(show: true)
        userDetailArray = []
        tableView.delegate = self
        tableView.dataSource = self
        userName = UserDefaults.standard.string(forKey: "username") as String!

        let postString = "username=\(String(describing: userName!))"
        let request = Constants.createRequest(url: Constants.friendsListUrl, postString: postString)

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
                if (status == "s") {
                    if let userDetails = json?.value(forKey: "friends") as? NSArray {
                        for userDetail in userDetails {
                            if let userDetailDict = userDetail as? NSDictionary {
                                var result = Result(game: "", name: "", username: "", nickname: "", platform: "")
                                if let user = userDetailDict.value(forKey: "name") {
                                    result.name = user as! String
                                }
                                if let username = userDetailDict.value(forKey: "username") {
                                    result.username = username as! String
                                }
                                if let game = userDetailDict.value(forKey: "game") {
                                    result.game = game as! String
                                }
                                if let nickname = userDetailDict.value(forKey: "nickname") {
                                    result.nickname = nickname as! String
                                }
                                if let platform = userDetailDict.value(forKey: "platform") {
                                    result.platform = platform as! String
                                }
                                self.userDetailArray.append(result)
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
        return isSearching ? filterUserArray.count : userDetailArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendViewCell
        if (isSearching) {
            cell.img_gameIcon.image = UIImage(named: Constants.gameReverseDict[filterUserArray[indexPath.row].game]!)
            cell.lbl_username.text = filterUserArray[indexPath.row].username
            cell.lbl_name.text = filterUserArray[indexPath.row].name
        } else {
            cell.img_gameIcon.image = UIImage(named: Constants.gameReverseDict[userDetailArray[indexPath.row].game]!)
            cell.lbl_username.text = userDetailArray[indexPath.row].username
            cell.lbl_name.text = userDetailArray[indexPath.row].name
        }
        cell.view_container.layer.cornerRadius = 10
        cell.view_container.layer.borderWidth = 2
        cell.view_container.layer.borderColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor.clear
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let statsController = storyboard?.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController
        if (isSearching) {
            statsController?.gamePass = filterUserArray[indexPath.row].game
            statsController?.uname = filterUserArray[indexPath.row].username
            statsController?.nickNamePass = filterUserArray[indexPath.row].nickname
            statsController?.platformPass = filterUserArray[indexPath.row].platform
        } else {
            statsController?.gamePass = userDetailArray[indexPath.row].game
            statsController?.uname = userDetailArray[indexPath.row].username
            statsController?.nickNamePass = userDetailArray[indexPath.row].nickname
            statsController?.platformPass = userDetailArray[indexPath.row].platform
        }

        self.navigationController?.pushViewController(statsController!, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var frndName: String?
        var gameName: String?
        if (editingStyle == .delete) {
            if (isSearching) {
                frndName = filterUserArray[indexPath.row].username
                gameName = filterUserArray[indexPath.row].game
            } else {
                frndName = userDetailArray[indexPath.row].username
                gameName = userDetailArray[indexPath.row].game
            }

            let alert = UIAlertController(title: "Delete friend", message: "Are you sure you want to delete this friend?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                self.deleteFriend(gameName: gameName!, frndName: frndName!)
            }
            let noAction = UIAlertAction(title: "No", style: .cancel) { action in
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func deleteFriend(gameName: String, frndName: String) {
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: gameName))&f_username=\(String(describing: frndName))"

        let request = Constants.createRequest(url: Constants.removeFriendURL, postString: postString)
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
                        self.friendLoad()
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //Function for filtering the table view cells based on what the user types in search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if ((searchBar.text == nil) || (searchBar.text == "")) {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filterUserArray = userDetailArray.filter({ $0.name.contains(searchBar.text!) })
            tableView.reloadData()
        }
    }

    struct Result {
        var game: String
        var name: String
        var username: String
        var nickname: String
        var platform: String
    }

}
