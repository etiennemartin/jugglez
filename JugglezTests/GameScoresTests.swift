//
//  GameScoresTests.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-04-25.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import UIKit
import XCTest
import Jugglez

class GameScoresTests: XCTestCase {
    override func setUp() {
        super.setUp()

        // Init the GameScores singleton
        GameScores.sharedInstance
        GameScores.sharedInstance.disableGameCenter()
    }

    override func tearDown() {
        // Reset all values
        GameScores.sharedInstance.resetScores()

        super.tearDown()
    }

    // Base easy mode setting test
    func testEasyScore() {
        GameScores.sharedInstance.resetScores()

        // Test initial condition
        XCTAssertEqual(0, GameScores.sharedInstance.easyHighScore, "Initial values for Easy Mode are incorrect")

        for var index: Int64 = 0; index < 1000; index+=100 {
            GameScores.sharedInstance.easyHighScore = index
            XCTAssertEqual(index, GameScores.sharedInstance.easyHighScore, "failed to set easy score of \(index)")
        }
    }

    // Base medium mode setting test
    func testMediumScore() {

        GameScores.sharedInstance.resetScores()

        // Test initial condition
        XCTAssertEqual(0, GameScores.sharedInstance.mediumHighScore, "Initial values for Medium Mode are incorrect")

        for var index: Int64 = 0; index < 1000; index+=100 {
            GameScores.sharedInstance.mediumHighScore = index
            XCTAssertEqual(index, GameScores.sharedInstance.mediumHighScore, "failed to set medium score of \(index)")
        }
    }

    // Base hard mode setting test
    func testHardScore() {
        GameScores.sharedInstance.resetScores()

        // Test initial condition
        XCTAssertEqual(0, GameScores.sharedInstance.hardHighScore, "Initial values for Hard Mode are incorrect")

        for var index: Int64 = 0; index < 1000; index+=100 {
            GameScores.sharedInstance.hardHighScore = index
            XCTAssertEqual(index, GameScores.sharedInstance.hardHighScore, "failed to set hard score of \(index)")
        }
    }

    // Base export mode setting test
    func testExpertScore() {
        GameScores.sharedInstance.resetScores()

        // Test initial condition
        XCTAssertEqual(0, GameScores.sharedInstance.expertHighScore, "Initial values for Export Mode are incorrect")

        for var index: Int64 = 0; index < 1000; index+=100 {
            GameScores.sharedInstance.expertHighScore = index
            XCTAssertEqual(index, GameScores.sharedInstance.expertHighScore, "failed to set expert score of \(index)")
        }
    }

    // Test score reset for all modes
    func testResetScores() {
        // Set base scores
        setAllScoreValues(100)

        // Reset values
        GameScores.sharedInstance.resetScores()

        // Validate reset values
        for mode in GameMode.allModes {
            XCTAssertEqual(0, GameScores.sharedInstance.getScoreForMode(mode), "Failed to reset \(mode.description) score")
        }
    }

    // Test high score flag for all modes
    func testHighScoreFlags() {
        GameScores.sharedInstance.resetScores()

        // Set base scores
        setAllScoreValues(100)

        // Test all modes
        for mode in GameMode.allModes {
            XCTAssert(GameScores.sharedInstance.isRecordNewForMode(mode), "New \(mode.description) high score flag is false and shouldn't be.")
        }
    }

    // Tests the Get and Set for each mode
    func testScoreAccessors() {
        GameScores.sharedInstance.resetScores()
        let score: Int64 = 10

        for mode in GameMode.allModes {
            GameScores.sharedInstance.setScoreForMode(mode, score: score)
            XCTAssertEqual(score, GameScores.sharedInstance.getScoreForMode(GameMode.Easy), "Failed to get/set score for mode: \(mode.description)")
        }
    }

    // Archiving test (Serialization/Deserialization)
    func testArchiving() {
		var archivePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
		archivePath = NSURL(fileURLWithPath: archivePath).URLByAppendingPathComponent("game_score_testing_archive").path!

        GameScores.sharedInstance.resetScores()

        // Set Scores
        var i: Int64 = 0
        for mode in GameMode.allModes {
            GameScores.sharedInstance.setScoreForMode(mode, score: i)
            ++i
        }

        // Save archive
        let encodedData: NSData = NSKeyedArchiver .archivedDataWithRootObject(GameScores.sharedInstance)
        let serializeResult = encodedData.writeToFile(archivePath, atomically: true)
        XCTAssertTrue(serializeResult, "Failed to serialize GameScores archive")

        // Load archive
        let data = try? NSData(contentsOfFile: archivePath, options: .DataReadingMappedIfSafe)
        let gameScoresInstance = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! GameScores?
        XCTAssertNotNil(gameScoresInstance, "Failed to create GameScores instance from archive")

        // Validate Scores
        i = 0
        for mode in GameMode.allModes {
            XCTAssertEqual(i, gameScoresInstance!.getScoreForMode(mode), "Score comparison failed during seriliazation for mode: \(mode.description)")
            ++i
        }

        let deleteResult: Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(archivePath)
            deleteResult = true
        } catch _ {
            deleteResult = false
        }
        XCTAssertTrue(deleteResult, "Failed to clean up after archive test. Testing archive remains")
    }

    // MARK: - Helpers

    // Sets the score for each mode
    private func setAllScoreValues(value: Int64) {
        GameScores.sharedInstance.easyHighScore   = value
        GameScores.sharedInstance.mediumHighScore = value
        GameScores.sharedInstance.hardHighScore   = value
        GameScores.sharedInstance.expertHighScore = value
    }
}
