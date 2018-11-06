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

    var gameName: String?
    var userName: String?
    var searchValue: String?
    var userDetailArray = [Result]()
    //filterUserArray is used to store filtered data based on what the user is typing in search bar
    var filterUserArray = [Result]()
    var isSearching = false

    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
        //Setting the Search Bar
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

        userDetailArray = []
        tableView.delegate = self
        tableView.dataSource = self
        showOrHideActivityIndicator(show: true)
        //Calling the Search URl API by passing the username, gamename and search value. We are passing '%' for the first time when the screen is loaded so as to retuen all the user who have that gamename added in profile
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: gameName!))&search=\(String(describing: searchValue!))"
        let request = Constants.createRequest(url: Constants.searchURL, postString: postString)

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
                if (status == "s") {
                    //Is the JSON data is parsed successfully then we are storing the in game name of the user, name, username, game name and is_friend in the Result struct
                    if let userDetails = json?.value(forKey: "results") as? NSArray {
                        for userDetail in userDetails {
                            if let userDetailDict = userDetail as? NSDictionary {
                                var result = Result(game: "", in_game_name: "", is_friend: false, name: "", username: "")
                                if let user = userDetailDict.value(forKey: "in_game_name") {
                                    result.in_game_name = user as! String
                                }
                                if let user = userDetailDict.value(forKey: "name") {
                                    result.name = user as! String
                                }
                                if let user = userDetailDict.value(forKey: "username") {
                                    result.username = user as! String
                                }
                                if let game = userDetailDict.value(forKey: "game") {
                                    result.game = game as! String
                                }
                                if let isf = userDetailDict.value(forKey: "is_friend") {
                                    result.is_friend = isf as! Bool
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
                self.showError(message: Constants.error_internet)
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
        if (isSearching) {
            return filterUserArray.count
        }
        else {
            return userDetailArray.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }

    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell") as! ShareViewCell
        //if user is typing name of user in searchbar and there are matches then the results are fetched from filterUserArray else it's fetched from UserDetailArray
        if (isSearching) {
            cell.img_gameIcon.image = UIImage(named: filterUserArray[indexPath.row].game)
            cell.lbl_username.text = filterUserArray[indexPath.row].username
            cell.lbl_inGameName.text = filterUserArray[indexPath.row].in_game_name
            cell.lbl_name.text = filterUserArray[indexPath.row].name
            cell.btn_add.isHidden = filterUserArray[indexPath.row].is_friend
        } else {
            cell.img_gameIcon.image = UIImage(named: userDetailArray[indexPath.row].game)
            cell.lbl_username.text = userDetailArray[indexPath.row].username
            cell.lbl_inGameName.text = userDetailArray[indexPath.row].in_game_name
            cell.lbl_name.text = userDetailArray[indexPath.row].name
            cell.btn_add.isHidden = userDetailArray[indexPath.row].is_friend
        }
        cell.btn_add.tag = indexPath.row
        cell.btn_add.addTarget(self, action: #selector(didTapAdd(sender:)), for: .touchUpInside)
        cell.view_container.layer.cornerRadius = 10
        cell.view_container.layer.borderWidth = 2
        cell.view_container.layer.borderColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor.clear
        return cell
    }

    @IBAction func didTapAdd(sender: UIButton) {
        let index = sender.tag
        var f_username: String?
        var game: String?
        if (isSearching) {
            f_username = filterUserArray[index].username
            game = filterUserArray[index].game
        } else {
            f_username = userDetailArray[index].username
            game = userDetailArray[index].game
        }

        let alert = UIAlertController(title: "Add friend", message: "Are you sure you want to add this user as friend?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.addFriend(game: game!, f_username: f_username!)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { action in
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }

    func addFriend(game: String, f_username: String) {
        showOrHideActivityIndicator(show: true)
        let postString = "username=\(String(describing: userName!))&game=\(String(describing: game))&f_username=\(String(describing: f_username))"
        let request = Constants.createRequest(url: Constants.addFriendURL, postString: postString)

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Result Structure is used to store the game name, the name of the user in the game, a boolean value is_friend, name of the users and their registered username in Let's Play app
    struct Result {
        var game: String
        var in_game_name: String
        var is_friend: Bool
        var name: String
        var username: String
    }
}
