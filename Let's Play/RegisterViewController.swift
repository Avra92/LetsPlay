//
//  RegisterViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 8/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var fullName: UITextField!

    // Creating Gender List
    let GenderList = ["Male", "Female"]
    var GenderMenu = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        GenderMenu.dataSource = self
        GenderMenu.delegate = self
        GenderMenu.backgroundColor = UIColor.gray
        gender.inputView = GenderMenu

        // Do any additional setup after loading the view.
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
        gender.text = GenderList[row]
        gender.resignFirstResponder()
    }


    @IBAction func Register(_ sender: UIButton) {
        let uname = username.text
        let pass = password.text
        let conPass = confirmPass.text
        let Email = email.text
        let Gender = gender.text
        let name = fullName.text
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,15}")

        //Checking whether there are any empty fields or not
        if ((uname?.isEmpty)! || (pass?.isEmpty)! || (conPass?.isEmpty)! || (Email?.isEmpty)! || (Gender?.isEmpty)! || (name?.isEmpty)!) {
            self.present(Constants.createAlert(title: "Error", message: "All fields must be filled"), animated: true, completion: nil)
            return
        }

        //Checking whether password and confirm password fields match or not
        if (pass != conPass) {
            self.present(Constants.createAlert(title: "Error", message: "Passwords didn't match"), animated: true, completion: nil)
            return
        }

        //Password validation it must have atleast 6 characters, 1 uppercase,1 lower case alphabet and 1 special character
        if (passwordTest.evaluate(with: pass) == false) {
            self.present(Constants.createAlert(title: "Error", message: "Your password is not strong. Please make sure it has 6-15 characters, upper and lower case alphabets and special characters"), animated: true, completion: nil)
            return
        }

        let postString = "username=\(String(describing: uname!))&password=\(String(describing: pass!))&email=\(String(describing: Email!))&gender=\(String(describing: Gender!))&name=\(String(describing: name!))&device=ios"
        let request = Constants.createRequest(url: Constants.registerURL, postString: postString)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any]
                print("JSON Data : \(String(describing: json))")
                let status = (json!["status"] as? String)!
                let message = (json!["message"] as? String)!
                if (status == "s") {
                    DispatchQueue.main.async(execute: {
                        self.present(Constants.createAlert(title: "Success", message: message), animated: true, completion: nil)
                    })
                }
                if (status == "e") {
                    DispatchQueue.main.async(execute: {
                        self.present(Constants.createAlert(title: "Error", message: message), animated: true, completion: nil)
                    })
                }
            } catch let error as NSError {
                print("Failed to load : \(error.localizedDescription)")
            }

        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
