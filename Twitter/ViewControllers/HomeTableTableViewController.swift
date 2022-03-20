//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Mark on 3/5/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeTableTableViewController: UITableViewController {
    private var tweetArray = [NSDictionary]()
    private var userInfo = NSDictionary()
    private var userBanner = NSDictionary()
    private var numberOfTweets = 0
    private let myRefreshControl = UIRefreshControl()
    private let profileURL = "https://api.twitter.com/1.1/account/verify_credentials.json"

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        appearance.backgroundColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 150
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
   }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
        loadUserInfo()
    }
    
    @objc func loadTweets() {
        let homeTimelineEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": 20]
        TwitterAPICaller.client?.getDictionariesRequest(url: homeTimelineEndpoint, parameters: myParams, success: { tweets in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { error in
            print(error.localizedDescription)
            print("Could not retrieve tweets! oh no!!")
        })
    }
    
    private func loadUserInfo () {
        TwitterAPICaller.client?.getDictionaryRequest(url: profileURL, parameters: [:], success: { UserInfo in
            self.userInfo = UserInfo
            // Passing userInfo to adjacent tab view controller
            // I don't think this is a good practice for doing so but it works for now
            let secondTab = self.tabBarController?.viewControllers?[1] as! UINavigationController
            let secondController = secondTab.topViewController as! ProfileViewController
            secondController.userInfo = UserInfo
        }, failure: { error in
            print("Error grabbing user profile image: \(error)")
        })
        
    }
    
    private func loadMoreTweets () {
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = ["count": numberOfTweets, "include_entities": true] as [String : Any]
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { tweets in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { error in
            print(error.localizedDescription)
            print("Could not retrieve tweets! oh no!!")
        })
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        
        var profileImageUrlString = user["profile_image_url"] as! String
        profileImageUrlString = profileImageUrlString.replacingOccurrences(of: "normal", with: "bigger")
        let profileImageURL = URL(string: profileImageUrlString)!
        // Make the image circular
        cell.profileImageView.af_setImage(withURL: profileImageURL)
        cell.profileImageView.layer.borderWidth = 2.0
        cell.profileImageView.layer.masksToBounds = false
        cell.profileImageView.layer.borderColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2
        cell.profileImageView.clipsToBounds = true
        
        configureEmbeddedMediaView(for: cell, at: indexPath)
        
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.retweetCountLabel.text = String(tweetArray[indexPath.row]["retweet_count"] as! Int)
        cell.retweeted = tweetArray[indexPath.row]["retweeted"] as! Bool
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        cell.favoriteCountLabel.text = String(tweetArray[indexPath.row]["favorite_count"] as! Int)
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        
        cell.screenNameLabel.text = "@" + (user["screen_name"] as! String)
        cell.userNameLabel.text = user["name"] as? String
        
        // Formatting relative tweet timestamp
        let createdDate = createDate(from: (tweetArray[indexPath.row]["created_at"] as? String)!)
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        cell.timestampLabel.text = formatter.localizedString(for: createdDate, relativeTo: Date())
        
    
        var tweetContent = (tweetArray[indexPath.row]["text"] as! String)
        tweetContent = tweetContent.replacingOccurrences(of: "&amp;", with: "&")
        cell.tweetContent.text = tweetContent
        
        return cell
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    private func createDate (from formattedString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return dateFormatter.date(from: formattedString )!
    }
    
    private func configureEmbeddedMediaView (for cell: TweetCell, at indexPath: IndexPath) {
        let extended_entities = (tweetArray[indexPath.row]["extended_entities"] as? NSDictionary )
        let mediaObject = extended_entities?["media"] as? NSArray
        if (mediaObject != nil) {
            let mediaUrlString = (mediaObject?[0] as? NSDictionary)?["media_url_https"]
            if (mediaUrlString != nil) {

                var moddedString = (mediaUrlString as! String).replacingOccurrences(of: ".jpg", with: "")
                moddedString = moddedString + "?format=jpg&name=small"
                let mediaURL = URL(string: moddedString)
                
                cell.mediaImageView.af_setImage(withURL: mediaURL!)
                cell.mediaImageView.layer.borderWidth = 3.0
                cell.mediaImageView.layer.masksToBounds = false
                cell.mediaImageView.layer.borderColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
                cell.mediaImageView.layer.cornerRadius = 10.0
                cell.mediaImageView.clipsToBounds = true
            }
        } else {
            cell.mediaImageView.image = nil
        }
    }

}

