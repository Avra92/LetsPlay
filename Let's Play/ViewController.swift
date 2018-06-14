//
//  ViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 4/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Login(_ sender: UIButton) {
        let uname = username.text
        let pass = password.text
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/login.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: uname!))&password=\(String(describing: pass!))&device=ios"
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
            let Data = responseString?.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            do
            {
                let json = try JSONSerialization.jsonObject(with: Data!, options: []) as? [String: Any]
                print("JSON Data : \(String(describing: json))")
                let status = (json!["status"] as? String)!
                let message = (json!["message"] as? String)!
                if (status == "s")
                {
                    DispatchQueue.main.async(execute:{
                        UserDefaults.standard.set("\(String(describing: uname!))", forKey: "username")
                        let homeController = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                        self.navigationController?.pushViewController(homeController!, animated: true)
                    })
                }
                if (status == "e"){
                    DispatchQueue.main.async(execute:{
                        let myAlert = UIAlertController(title: "Login Failed", message: "\(message)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            print("Login Failed")
                        }
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion:nil)
                    })
                    return
                }
            }
            catch let error as NSError{
                print("Failed to load : \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    @IBAction func register(_ sender: UIButton) {
        let registerController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController
        self.navigationController?.pushViewController(registerController!, animated: true)
    }
    
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        let forgotPassController = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPassViewController") as? ForgotPassViewController
        self.navigationController?.pushViewController(forgotPassController!, animated: true)
    }
}

