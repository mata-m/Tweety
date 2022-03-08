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
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.titleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
            appearance.largeTitleTextAttributes = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
            appearance.backgroundColor = #colorLiteral(red: 0, green: 0.6784657836, blue: 0.9941992164, alpha: 1)

            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
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
            print("Could not retreive tweets! oh no!!")
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
            print("Could not retreive tweets! oh no!!")
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
        
        cell.profileImageView.af_setImage(withURL: profileImageURL)
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as! String
        
        return cell
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
