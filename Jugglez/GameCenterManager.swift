//
//  GameCenterManager.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-04-12.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import Foundation
import GameKit

// MARK: Game Center Manager delegate.
protocol GameCenterManagerDelegate {
    func processGameCenterAuth(error:NSError?)
    func scoreReported(leadershipId:String, error:NSError?)
    func reloadScoresComplete(leaderBoard:GKLeaderboard, error:NSError?)
    func achievementSubmitted(achievement:GKAchievement?, error:NSError?)
    func achievementResetResult(error:NSError?)
    func mappedPlayerIDToPlayer(player:GKPlayer?, error:NSError?)
}

// MARK: Game Center Manager
// Game Center Manager takes care of the communication between the app and Apple's
// Game Center service.
class GameCenterManager : NSObject {
    
    override init() {
        super.init()
    }
    
    // Singleton access
    class var sharedInstance : GameCenterManager {
        
        struct InstanceStruct {
            static var instanceToken : dispatch_once_t = 0
            static var instance : GameCenterManager? = nil
        }
        
        // Load the data from file at start up.
        dispatch_once(&InstanceStruct.instanceToken) {
            InstanceStruct.instance = GameCenterManager()
        }
        
        return InstanceStruct.instance!
    }
    
    // Authenticates the local user with the Game Center Service
    func authenticateLocalUser() {

        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = {(viewController : UIViewController?, error : NSError?) -> Void in
            if ((viewController) != nil) {
                self.authViewController = viewController
                NSNotificationCenter.defaultCenter().postNotificationName(GameCenterManager.presentGameCenterNotificationViewController, object: self)
            } else if (GKLocalPlayer.localPlayer().authenticated) {
                self.authViewController = nil // release
                self.enabled = true
                print("GameCenter, localPlayer auth: %@", (GKLocalPlayer.localPlayer().authenticated))
            }
            
            if (self._delegate != nil) {
                self._delegate?.processGameCenterAuth(error)
            }
        }
    }
    
    // Reports a score to a leaderboard
    func reportScore(score:Int64, identifier:String) {
        
        if (enabled == false) {
            print("Can't submit score, local user isn't authenticated.")
            
            if (_delegate != nil) {
                let err : NSError = NSError(domain: "GameCenterManager", code: -1, userInfo: nil)
                _delegate?.scoreReported(identifier, error:err)
            }
            
            return
        }
        
        let scoreReporter : GKScore = GKScore(leaderboardIdentifier: identifier)
        scoreReporter.value = score
        GKScore.reportScores([scoreReporter], withCompletionHandler: { (error: NSError?) -> Void in
            if error != nil {
                print(NSString(format: "Failed to submit score for leaderboard: "+identifier+" err: ", error!.localizedDescription))
            } else {
                print("Score submitted for leaderboard:"+identifier)
            }
            
            if (self._delegate != nil) {
                self._delegate?.scoreReported(identifier, error:error)
            }
        })
    }
    
    // Reloads/Refreshes the score for a given leaderboard
    func reloadHighScoresForIdentity(identifier:String) {

        let leaderboard = GKLeaderboard()
        leaderboard.identifier = identifier
        leaderboard.loadScoresWithCompletionHandler { (scores:[GKScore]?, error: NSError?) -> Void in
            
            if error != nil {
                print(NSString(format: "Failed to reload scores: %@", error!.localizedDescription))
            } else {
                print(NSString(format: "Successfully reloaded scores for leaderboard: %@", leaderboard.identifier!))
            }
            
            if (self._delegate != nil) {
                self._delegate?.reloadScoresComplete(leaderboard, error: error)
            }
        }
    }
    
    // Submit an Achievement to the Game Center
    func submitAchievement(identifier:String, percentComplete:Double) {

        // GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report
        // new achievements to the user, then you need to check if it's been earned
        //
        // before you submit. Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
        // and reportAchievementWithCompletionHandler. To avoid this, we fetch the current achievement list once,
        // then cache it and keep it updated with any new achievements.
        if (_earnedAchievementCache == nil) {
            GKAchievement.loadAchievementsWithCompletionHandler({ (achievements:[GKAchievement]?, error:NSError?) -> Void in
				
                guard achievements == nil else {
                    return
                }
				
                if (error == nil) {
                    var tempCache : Dictionary<String, GKAchievement> = Dictionary<String, GKAchievement>()
                    for a in achievements! {
                        let achievement : GKAchievement = a
                        tempCache[achievement.identifier!] = achievement
                    }
                    self._earnedAchievementCache = tempCache
                    self.submitAchievement(identifier, percentComplete: percentComplete)
                } else {
                    // Something went wrong
                    if (self._delegate != nil) {
                        self._delegate?.achievementSubmitted(nil, error: error)
                    }
                }
            })
        } else {
            
            // Search the list for the ID we're using...
            var achievement : GKAchievement? = self._earnedAchievementCache![identifier]
            if (achievement != nil) {
                if (achievement?.percentComplete >= 100.0 || achievement?.percentComplete >= percentComplete) {
                    // Achievement was already completed
                    return
                }
                achievement?.percentComplete = percentComplete
            } else {
                achievement = GKAchievement(identifier: identifier)
                achievement?.percentComplete = percentComplete
                // Add achievement to the cache
                self._earnedAchievementCache![achievement!.identifier!] = achievement
            }
            
            if (achievement != nil) {
                // Submit the achievement
                GKAchievement.reportAchievements([achievement!], withCompletionHandler: { (error:NSError?) -> Void in
                    
                    if error != nil {
                        print(NSString(format: "Failed to report Achievement: %@", error!.localizedDescription))
                    } else {
                        print(NSString(format: "Successfully reported achievement"))
                    }
                    
                    if (self._delegate != nil) {
                        self._delegate?.achievementSubmitted(achievement, error: error)
                    }
                })
            }
            
        }
    }
    
    // Reset all cached achievements
    func resetAchievements() {

        _earnedAchievementCache = Dictionary<String, GKAchievement>()
        GKAchievement.resetAchievementsWithCompletionHandler { (error:NSError?) -> Void in

            if error != nil {
                print(NSString(format: "Failed to reset Achievements: %@", error!.localizedDescription))
            } else {
                print(NSString(format: "Successfully reset achievements"))
            }
            
            if (self._delegate != nil) {
                self._delegate?.achievementResetResult(error)
            }
        }
    }
    
    // Maps a player's ID to it's user defined ID.
    func mapPlayerIDtoPlayer(playerID:String) {

        if (_delegate == nil) {
            return
        }
        
        GKPlayer.loadPlayersForIdentifiers([playerID], withCompletionHandler: { (players:[GKPlayer]?, error:NSError?) -> Void in

            guard players == nil else {
                return
            }

            var player : GKPlayer? = nil
            for p in players! {
                let tmpPlayer : GKPlayer = p
                if (tmpPlayer.playerID == playerID) {
                    player = tmpPlayer
                    break
                }
            }
            
            self._delegate?.mappedPlayerIDToPlayer(player!, error: error)
        })
    }
    
    // Name of the NSNotification that is sent when the Game Center services requires the user
    // to authenticate
    class var presentGameCenterNotificationViewController : String {
        get { return "present_game_center_notification_view_controller" }
    }
    
    // Determines if the Game Center Manager is ready to be used. (i.e. user is authenticated with the 
    // service
    var enabled : Bool = false
    
    // Holds a reference to the UIViewController passed by the Game Center service during authentication
    var authViewController : UIViewController? = nil
    
    // List of cached achievments
    var earnedAchievementCache : Dictionary<String, GKAchievement>? {
        get {
            return _earnedAchievementCache
        }
    }
    var delegate : GameCenterManagerDelegate? {
        get {
            return _delegate;   
        }
        set (value) {
            _delegate = value
        }
    }
    
    private var _earnedAchievementCache : Dictionary<String, GKAchievement>? = Dictionary<String, GKAchievement>()
    private var _delegate : GameCenterManagerDelegate? = nil
    
}
