//
//  RegisterViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 8/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var txt_username: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_confirmPass: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_gender: UITextField!
    @IBOutlet weak var txt_fullName: UITextField!

    // Creating Gender List
    let GenderList = ["Male", "Female"]
    var GenderMenu = UIPickerView()

    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = UIActivityIndicatorView()
        GenderMenu.dataSource = self
        GenderMenu.delegate = self
        GenderMenu.backgroundColor = UIColor.gray
        txt_gender.inputView = GenderMenu

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

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GenderList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GenderList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txt_gender.text = GenderList[row]
        txt_gender.resignFirstResponder()
    }


    @IBAction func didTapRegister(_ sender: UIButton) {
        let uname = txt_username.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = txt_password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let conPass = txt_confirmPass.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = txt_email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender = txt_gender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = txt_fullName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,15}")

        //Checking whether there are any empty fields or not
        if (uname!.isEmpty || pass!.isEmpty || conPass!.isEmpty || email!.isEmpty || gender!.isEmpty || name!.isEmpty) {
            self.present(Constants.createAlert(title: "Error", message: "All fields must be filled"), animated: true, completion: nil)
            return
        }

        //Checking whether password and confirm password fields match or not
        if (pass != conPass) {
            self.present(Constants.createAlert(title: "Error", message: "Passwords didn't match"), animated: true, completion: nil)
            return
        }

        //Password validation it must have atleast 6 characters, 1 uppercase,1 lower case alphabet and 1 special character
        if (!passwordTest.evaluate(with: pass)) {
            self.present(Constants.createAlert(title: "Error", message: "Your password is not strong. Please make sure it has 6-15 characters, upper and lower case alphabets and special characters"), animated: true, completion: nil)
            return
        }

        showOrHideActivityIndicator(show: true)
        let postString = "username=\(String(describing: uname!))&password=\(String(describing: pass!))&email=\(String(describing: email!))&gender=\(String(describing: gender!))&name=\(String(describing: name!))&device=ios"
        let request = Constants.createRequest(url: Constants.registerURL, postString: postString)

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
