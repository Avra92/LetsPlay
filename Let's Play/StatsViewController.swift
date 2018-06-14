//
//  StatsViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 11/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var img_gameIcon: UIImageView!
    @IBOutlet weak var lbl_gameNick: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var gamePass: String?
    var nickNamePass: String?
    var platformPass: String?
    var uname: String?

    var statDetailArray = [String]()
    var statValueArray = [String]()

    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
        tableView.delegate = self
        tableView.dataSource = self
        img_gameIcon.image = UIImage(named: Constants.gameReverseDict[gamePass!]!)
        statDetailArray = []
        statValueArray = []
        showOrHideActivityIndicator(show: true)
        let postString = "username=\(String(describing: uname!))&game=\(String(describing: gamePass!))&nickname=\(String(describing: nickNamePass!))&platform=\(String(describing: platformPass!))"
        let request = Constants.createRequest(url: Constants.gameStatsURL, postString: postString)

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
                    if let statDetails = json?.value(forKey: "stats") as? NSArray {
                        for statDetail in statDetails {
                            if let statDetailDict = statDetail as? NSDictionary {
                                if let stat = statDetailDict.value(forKey: "key") {
                                    self.statDetailArray.append(stat as! String)
                                }
                                if let statValue = statDetailDict.value(forKey: "value") {
                                    self.statValueArray.append(statValue as! String)
                                }
                                OperationQueue.main.addOperation({
                                    self.tableView.reloadData()
                                })
                            }
                        }
                    }
                    if let inGameNick = json?.value(forKey: "in_game_name") as? String {
                        DispatchQueue.main.async(execute: {
                            self.lbl_gameNick.text = inGameNick
                        })
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
        return statDetailArray.count

    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "StatCell") as! StatViewCell
        cell.txt_statName.text = statDetailArray[indexPath.row]
        cell.txt_statValue.text = statValueArray[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

