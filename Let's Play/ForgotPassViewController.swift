//
//  ForgotPassViewController.swift
//  Let's Play
//
//  Created by Avra Ghosh on 9/06/18.
//  Copyright © 2018 Avra Ghosh. All rights reserved.
//

import UIKit

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func Submit(_ sender: UIButton) {
        let uname = username.text
        let url = URL(string: "https://www.jak2018.freehosting.co.nz/api/forgotpassword.php")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "username=\(String(describing: uname!))"
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
                        let myAlert = UIAlertController(title: " ", message: "\(message)", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { action in
                            self.dismiss(animated: true,completion: nil)
                        }
                        myAlert.addAction(okAction)
                        self.present(myAlert, animated: true, completion:nil)
                    })
                }
            }
            catch let error as NSError{
                print("Failed to load : \(error.localizedDescription)")
            }
        }
        task.resume()
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
