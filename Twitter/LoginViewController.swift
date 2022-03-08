//
//  LoginViewController.swift
//  Twitter
//
//  Created by Mark on 3/5/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "userLoggedIn") == true) {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        let authenticationURL = "https://api.twitter.com/oauth/request_token"
        TwitterAPICaller.client?.login(url: authenticationURL, success: {
            UserDefaults.standard.set(true, forKey: "userLoggedIn")
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }, failure: { Error in
            print(Error.localizedDescription)
          print("Could not login")
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
