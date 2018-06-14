//
//  ForgotPassViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 9/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var txt_username: UITextField!
    var activityIndicator: UIActivityIndicatorView?
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
        // Do any additional setup after loading the view.
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

    @IBAction func didTapSubmit(_ sender: UIButton) {
        let uname = txt_username.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        if (uname!.isEmpty) {
            self.present(Constants.createAlert(title: "Error", message: "Please enter your username"), animated: true, completion: nil)
            return
        }

        let postString = "username=\(String(describing: uname!))"
        let request = Constants.createRequest(url: Constants.forgotPasswordURL, postString: postString)

        showOrHideActivityIndicator(show: true)

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
            print("responseString = \(String(describing: responseString))")
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any]
                print("JSON Data : \(String(describing: json))")
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
                self.showError(message: Constants.error_internet)
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
