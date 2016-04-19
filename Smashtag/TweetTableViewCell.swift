//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private var hashtagColor = UIColor.blueColor()
    private var urlColor = UIColor.darkGrayColor()
    private var userMentionsColor = UIColor.orangeColor()
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    private func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet {
            var text = tweet.text
            
            for _ in tweet.media {
                text! += " 📷"
            }
            
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.changeKeywordsColor(tweet.hashtags, color: hashtagColor)
            attributedText.changeKeywordsColor(tweet.urls, color: urlColor)
            attributedText.changeKeywordsColor(tweet.userMentions, color: userMentionsColor)
            
            attributedText.changeKeywordsColor(tweet.mediaMentions, color: urlColor)
            
            tweetTextLabel?.attributedText = attributedText
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            self.tweetProfileImageView?.image = nil
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let imageData = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if imageData != nil {
                            self.tweetProfileImageView?.image = UIImage(data: imageData!)
                        }
                        if profileImageURL == tweet.user.profileImageURL {
                            if imageData != nil {
                                self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            }
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
            
            if tweet.hashtags.count + tweet.urls.count + tweet.userMentions.count + tweet.media.count > 0 {
                accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}

// MARK: - Extensions

private extension NSMutableAttributedString {
    func changeKeywordsColor(keywords: [Tweet.IndexedKeyword], color: UIColor) {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}
