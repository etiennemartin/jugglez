//
//  GameScores.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-01-22.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import Foundation
import GameKit

// NSCoding keys
private let kEasyHighScoreKey   = "easy_high_score_key"
private let kMediumHighScoreKey = "medium_high_score_key"
private let kHardHighScoreKey   = "hard_high_score_key"
private let kExpertHighScoreKey = "expert_high_score_key"
private let kGameScoreFileName  = "gameScores"

// Game Center Leaderboard Ids
private let kEasyModeLeaderboardId   = "com.jugglez.mode.easy"
private let kMediumModeLeaderboardId = "com.jugglez.mode.medium"
private let kHardModeLeaderboardId   = "com.jugglez.mode.hard"
private let kExpertModeLeaderboardId = "com.jugglez.mode.expert"

public class GameScores: NSObject, NSCoding, GameCenterManagerDelegate {

    // MARK: Singleton access

    public class var sharedInstance: GameScores {
        struct InstanceStruct {
            static var instanceToken: dispatch_once_t = 0
            static var instance: GameScores? = nil
        }

        // Load the data from file at start up.
        dispatch_once(&InstanceStruct.instanceToken) {

            GameCenterManager.sharedInstance.authenticateLocalUser()

            let filePath = GameScores.filePath()
            let data = try? NSData(contentsOfFile: filePath, options: NSDataReadingOptions.DataReadingMappedIfSafe)

            if data != nil {
                print("Loading high scores from archive...")
                InstanceStruct.instance = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! GameScores?
            } else {
                print("Creating new high scores...")
                InstanceStruct.instance = GameScores()
            }

            GameCenterManager.sharedInstance.delegate = InstanceStruct.instance
        }

        return InstanceStruct.instance!
    }

    // MARK: Class impl
    override init() {
        super.init()
    }

    public required init(coder aDecoder: NSCoder) {
        super.init()

        // Load from Local Archive
        _easyHighScore = aDecoder.decodeInt64ForKey(kEasyHighScoreKey)
        _mediumHighScore = aDecoder.decodeInt64ForKey(kMediumHighScoreKey)
        _hardHighScore = aDecoder.decodeInt64ForKey(kHardHighScoreKey)
        _expertHighScore = aDecoder.decodeInt64ForKey(kExpertHighScoreKey)
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeInt64(easyHighScore, forKey: kEasyHighScoreKey)
        coder.encodeInt64(mediumHighScore, forKey: kMediumHighScoreKey)
        coder.encodeInt64(hardHighScore, forKey: kHardHighScoreKey)
        coder.encodeInt64(expertHighScore, forKey: kExpertHighScoreKey)
    }

    // Set the high score for a mode if it's higher than the current one
    public func setScoreForMode(mode: GameMode, score: Int64) {

        switch mode {
        case GameMode.Easy:
            easyHighScore = max(easyHighScore, score)
            break
        case GameMode.Medium:
            mediumHighScore = max(mediumHighScore, score)
            break
        case GameMode.Hard:
            hardHighScore = max(hardHighScore, score)
            break
        case GameMode.Expert:
            expertHighScore = max(expertHighScore, score)
            break
        default:
            break
        }
    }

    public func getScoreForMode(mode: GameMode) -> Int64 {
        switch mode {
        case GameMode.Easy:
            return easyHighScore
        case GameMode.Medium:
            return mediumHighScore
        case GameMode.Hard:
            return hardHighScore
        case GameMode.Expert:
            return expertHighScore
        default:
            return 0
        }
    }

    public func isRecordNewForMode(mode: GameMode) -> Bool {
        switch mode {
        case GameMode.Easy:
            return _newEasyScore
        case GameMode.Medium:
            return _newMediumScore
        case GameMode.Hard:
            return _newHardScore
        case GameMode.Expert:
            return _newExpertScore
        default:
            return false
        }
    }

    // High Scores
    public var easyHighScore: Int64 {
        get {
            return _easyHighScore
        }
        set(value) {
            if _easyHighScore < value {
                _newEasyScore = true
                reportGameCenterScore(value, identifier: kEasyModeLeaderboardId)
            }
            _easyHighScore = value
        }
    }

    public var mediumHighScore: Int64 {
        get {
            return _mediumHighScore
        }
        set(value) {
            if _mediumHighScore < value {
                _newMediumScore = true
                reportGameCenterScore(value, identifier: kMediumModeLeaderboardId)
            }
            _mediumHighScore = value
        }
    }

    public var hardHighScore: Int64 {
        get {
            return _hardHighScore
        }
        set (value) {
            if _hardHighScore < value {
                _newHardScore = true
                reportGameCenterScore(value, identifier: kHardModeLeaderboardId)
            }
            _hardHighScore = value
        }
    }

    public var expertHighScore: Int64 {
        get {
            return _expertHighScore
        }
        set (value) {
            if _expertHighScore < value {
                _newExpertScore = true
                reportGameCenterScore(value, identifier: kExpertModeLeaderboardId)
            }
            _expertHighScore = value
        }
    }

    public func clearHighScoreFlags() {
        _newEasyScore = false
        _newMediumScore = false
        _newHardScore = false
        _newExpertScore = false
    }

    // Manually disable Game Center integration
    public func disableGameCenter() {
        _gameCenterEnabled = false
    }

    public func resetScores() {
        easyHighScore = 0
        mediumHighScore = 0
        hardHighScore = 0
        expertHighScore = 0
        save()
    }

    // Store data
    public func save() {
        let encodedData: NSData = NSKeyedArchiver .archivedDataWithRootObject(self)
        encodedData.writeToFile(GameScores.filePath(), atomically: true)
    }

    public func reportGameCenterScore(score: Int64, identifier: String) {
        if _gameCenterEnabled == false {
            return
        }

        if GameCenterManager.sharedInstance.enabled == true {
            GameCenterManager.sharedInstance.reportScore(score, identifier: identifier)
        }
    }

    // Generate a path for the game scores file
    private class func filePath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return NSURL(fileURLWithPath: documentsPath).URLByAppendingPathComponent(kGameScoreFileName).path!
    }

    private func reloadLeaderboards() {
        if GameCenterManager.sharedInstance.enabled == false {
            return
        }

        GameCenterManager.sharedInstance.reloadHighScoresForIdentity(kEasyModeLeaderboardId)
        GameCenterManager.sharedInstance.reloadHighScoresForIdentity(kMediumModeLeaderboardId)
        GameCenterManager.sharedInstance.reloadHighScoresForIdentity(kHardModeLeaderboardId)
        GameCenterManager.sharedInstance.reloadHighScoresForIdentity(kExpertModeLeaderboardId)
    }

    // MARK: GameCenterManagerDelegate methods
    internal func processGameCenterAuth(error: NSError?) {
        if error == nil {
            reloadLeaderboards()
        } else {
            print("Failed to authenticate with game center err:"+error.debugDescription)
        }
    }

    internal func scoreReported(leaderboardId: String, error: NSError?) {
        if error != nil {
            print("Failed to report "+leaderboardId+" score. err="+error!.debugDescription)
        }
    }

    internal func reloadScoresComplete(leaderBoard: GKLeaderboard, error: NSError?) {

        var oldScore: Int64 = 0
        var curScore: Int64 = 0
        var gcScore: Int64 = 0

        if leaderBoard.localPlayerScore != nil {
            gcScore = leaderBoard.localPlayerScore!.value
        }

        if leaderBoard.identifier == kEasyModeLeaderboardId {
            oldScore = _easyHighScore
            _easyHighScore = max(oldScore, gcScore)
            curScore = _easyHighScore
        } else if leaderBoard.identifier == kMediumModeLeaderboardId {
            oldScore = _mediumHighScore
            _mediumHighScore = max(oldScore, gcScore)
            curScore = _mediumHighScore
        } else if leaderBoard.identifier == kHardModeLeaderboardId {
            oldScore = _hardHighScore
            _hardHighScore = max(oldScore, gcScore)
            curScore = _hardHighScore
        } else if leaderBoard.identifier == kExpertModeLeaderboardId {
            oldScore = _expertHighScore
            _expertHighScore = max(oldScore, gcScore)
            curScore = _expertHighScore
        }

        // Update Game Center with local score if it has changed (offline)
        if curScore != gcScore && GameCenterManager.sharedInstance.enabled == true {
            GameCenterManager.sharedInstance.reportScore(curScore, identifier: leaderBoard.identifier!)
        }

    }

    internal func achievementSubmitted(achievement: GKAchievement?, error: NSError?) {
        // Reserved for future use
    }

    internal func achievementResetResult(error: NSError?) {
        // Reserved for future use
    }

    internal func mappedPlayerIDToPlayer(player: GKPlayer?, error: NSError?) {
        // Reserved for future use
    }

    // MARK: Private members
    private var _newEasyScore: Bool    = false
    private var _newMediumScore: Bool  = false
    private var _newHardScore: Bool    = false
    private var _newExpertScore: Bool  = false

    private var _easyHighScore: Int64    = 0
    private var _mediumHighScore: Int64  = 0
    private var _hardHighScore: Int64    = 0
    private var _expertHighScore: Int64  = 0

    private var _gameCenterEnabled: Bool = true
}
