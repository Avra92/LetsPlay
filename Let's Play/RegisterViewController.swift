//
//  RegisterViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 8/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    // Creating Gender List
    let GenderList =     [ "Male","Female"]
    var GenderMenu     = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GenderMenu.dataSource = self
        GenderMenu.delegate = self
        GenderMenu.backgroundColor = UIColor.gray
        gender.inputView = GenderMenu
        
        // Do any additional setup after loading the view.
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
       return GenderList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
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
        if ((uname?.isEmpty)! || (pass?.isEmpty)! || (conPass?.isEmpty)! || (Email?.isEmpty)! || (Gender?.isEmpty)! || (name?.isEmpty)!)
        {
            showAlert(userMessage: "All fields must be filled!")
        }
        
        //Checking whether password and confirm password fields match or not
        if (pass != conPass)
        {
            showAlert(userMessage: "Passwords didn't match!")
        }
        
        //Password validation it must have atleast 6 characters, 1 uppercase,1 lower case alphabet and 1 special character
        if (passwordTest.evaluate(with: pass) == false) {
            showAlert(userMessage: "Your password is not strong, please make sure it has 6-15 characters, upper and lower case alphabets and some special characters")
        }
        
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/register.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: uname!))&password=\(String(describing: pass!))&email=\(String(describing: Email!))&gender=\(String(describing: Gender!))&name=\(String(describing: name!))"
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
                       let myAlert = UIAlertController(title: "Successful", message: "Registration successful. Thank you!", preferredStyle: .alert)
                       let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                           self.dismiss(animated: true,completion: nil)
                       }
                       myAlert.addAction(okAction)
                       self.present(myAlert, animated: true, completion:nil)
                    })
                }
                if (status == "e"){
                    DispatchQueue.main.async(execute:{
                        self.showAlert(userMessage: "\(String(describing: message))")
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
    
    func showAlert(userMessage: String){
        let alert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (alert: UIAlertAction!) -> Void in
            print("Ok")
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion:nil)
        return
        
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
