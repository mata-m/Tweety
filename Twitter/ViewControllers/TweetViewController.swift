//
//  TweetViewController.swift
//  Twitter
//
//  Created by Mark on 3/13/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit
import AlamofireImage

class TweetViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetCharCountLabel: UILabel!
    
    private var profileImageURL: String = ""
    private let profileEndpoint = "https://api.twitter.com/1.1/account/verify_credentials.json"
    
    @IBAction func cancelTweet(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tweet(_ sender: Any) {
        if (!tweetTextView.text.isEmpty) {
            TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {
                self.dismiss(animated: true, completion: nil)
            }, failure: { (Error) in
                print("Error posting tweet \(Error)")
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            print("Didn't post tweet")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc(textView:shouldChangeTextInRange:replacementText:) func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        
        // Set the max character limit
        let characterLimit = 280

        // Construct what the new text would be if we allowed the user's latest edit
        let newText = NSString(string: textView.text!).replacingCharacters(in: range, with: text)

        // Update Character Count Label
        tweetCharCountLabel.text = String(newText.count)
        tweetCharCountLabel.textColor = newText.count >= characterLimit ? #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) : #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

        // The new text should be allowed? True/False
        return newText.count < characterLimit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.delegate = self
        configureTweet()
        tweetTextView.becomeFirstResponder()
    }
    
    private func configureTweet () {
        configureTweetNavBar()
        configureTweetProfileImage()
        configureTweetTextView()
    }
    
    private func configureTweetTextView () {
        tweetTextView.layer.borderColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
        tweetTextView.layer.borderWidth = 2.0
        tweetTextView.layer.cornerRadius = 5.0
    }
    
    private func configureTweetProfileImage () {
        TwitterAPICaller.client?.getDictionaryRequest(url: profileEndpoint, parameters: [:], success: { UserInfo in
            self.profileImageView.af_setImage(withURL: URL(string: UserInfo["profile_image_url_https"] as! String)!)
        
        }, failure: { error in
            print("Error grabbing user profile image: \(error)")
        })
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
    }
    
    private func configureTweetNavBar () {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        appearance.backgroundColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
}
