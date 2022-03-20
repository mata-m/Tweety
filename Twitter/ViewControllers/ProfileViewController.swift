//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Mark on 3/17/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit
import Foundation
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var joinDateLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    private let subviewSize = CGSize(width: 73.0, height: 73.0)
    private let margin = 16.0
    var userInfo = NSDictionary()
    var userBannerUrls = NSDictionary()
    var numberOfTweets = 0
    var tweetArray = [NSDictionary]()
    
    let myRefreshControl = UIRefreshControl()


    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let profileImageUrlString:String = (userInfo["profile_image_url_https"] as! String).replacingOccurrences(of: "normal", with: "bigger")
        self.profileImageView.af_setImage(withURL: URL(string: profileImageUrlString)!)
        
        configureBanner()
        
        let dateString = (userInfo["created_at"] as! String)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        joinDateLabel.text = "🗓 Joined " + dateString.toDateString(dateFormatter: dateFormatter, outputFormat: "MMM YYYY")!
        
        
        userName.text = (userInfo["name"] as! String)
        userScreenName.text = "@" + (userInfo["screen_name"] as! String)
        followerCountLabel.text = String(userInfo["followers_count"] as! Int)
        followingCountLabel.text = String(userInfo["friends_count"] as! Int)
    
        
        
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        let profileImageLeadingConstraint = profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                                        constant: margin)
        let profileImageTopConstraint = profileImageView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor,
                                                                              constant: CGFloat(-(subviewSize.height / 2.0)))
        NSLayoutConstraint.activate([//profileImageHeightConstraint,
            profileImageTopConstraint,
            //profileImageWidthConstraint,
            profileImageLeadingConstraint])
        
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        profileImageView.layer.cornerRadius = 10.0
        profileImageView.clipsToBounds = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTweets()
    }
    
    @objc func loadTweets() {
        let userTimelineEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let myParams = [ "id": userInfo["id"] as! Int , "count": 20]
        TwitterAPICaller.client?.getDictionariesRequest(url: userTimelineEndpoint, parameters: myParams, success: { tweets in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { error in
            print(error.localizedDescription)
            print("Could not retrieve user profile tweets! oh no!!")
        })
    }
    
    func loadMoreTweets() {
        let userTimelineEndpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        numberOfTweets = numberOfTweets + 20
        let myParams = [ "id": userInfo["id"] as! Int, "count": numberOfTweets, "include_entities": true] as [String : Any]
        TwitterAPICaller.client?.getDictionariesRequest(url: userTimelineEndpoint, parameters: myParams, success: { tweets in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { error in
            print(error.localizedDescription)
            print("Could not retrieve more user profile tweets! oh no!!")
        })
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func createDate (from formattedString: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return dateFormatter.date(from: formattedString )!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
    
    private func configureBanner () {
        let bannerEndpoint = "https://api.twitter.com/1.1/users/profile_banner.json"
        var bannerImageUrlString = ""
        let userId = self.userInfo["id"] as! Int
        TwitterAPICaller.client?.getDictionaryRequest(url: bannerEndpoint, parameters: ["user_id": userId], success: { UserInfo in
            self.userBannerUrls = UserInfo
            bannerImageUrlString = ((UserInfo["sizes"] as! NSDictionary)["mobile_retina"] as! NSDictionary)["url"] as! String
            self.bannerImageView.af_setImage(withURL: URL(string: bannerImageUrlString)!)
        }, failure: { error in
            print("Error grabbing banner profile image: \(error)")
        })
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

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
extension String {

    func toDate (dateFormatter: DateFormatter) -> Date? {
        return dateFormatter.date(from: self)
    }

    func toDateString (dateFormatter: DateFormatter, outputFormat: String) -> String? {
        guard let date = toDate(dateFormatter: dateFormatter) else { return nil }
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = outputFormat
        return newDateFormatter.string(from: date)
    }
}
