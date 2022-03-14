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
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets = 0
    
    
    let myRefreshControl = UIRefreshControl()

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
    
    func loadMoreTweets() {
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = ["count": numberOfTweets]
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
        var tweetContent = (tweetArray[indexPath.row]["text"] as! String)
        tweetContent = tweetContent.replacingOccurrences(of: "&amp;", with: "&")
        
        cell.profileImageView.af_setImage(withURL: profileImageURL)
        
        cell.retweetCountLabel.text = String(tweetArray[indexPath.row]["retweet_count"] as! Int)
        cell.favoriteCountLabel.text = String(tweetArray[indexPath.row]["favorite_count"] as! Int)
        cell.screenNameLabel.text = "@" + (user["screen_name"] as! String)
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetContent
        
        // Make the image circular
        cell.profileImageView.layer.borderWidth = 2.0
        cell.profileImageView.layer.masksToBounds = false
        cell.profileImageView.layer.borderColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2
        cell.profileImageView.clipsToBounds = true
        
        let createdDate = createDate(from: (tweetArray[indexPath.row]["created_at"] as? String)!)
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        cell.timestampLabel.text = formatter.localizedString(for: createdDate, relativeTo: Date())
        
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.retweeted = tweetArray[indexPath.row]["retweeted"] as! Bool
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        
        
        return cell
    }
    
    
    func createDate (from formattedString: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return dateFormatter.date(from: formattedString )!
    }
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }

    

    
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let destination = segue.destination as! TweetViewController
        // Pass the selected object to the new view controller.
        
    }
  */

}
