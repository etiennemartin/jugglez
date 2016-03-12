//
//  SKColor+Theme.swift
//  Jugglez
//
//  Created by Etienne Martin on 2015-03-22.
//  Copyright (c) 2015 Etienne Martin. All rights reserved.
//

import SpriteKit

extension SKColor {
    // General colors
    class func themeLightBackgroundColor() -> SKColor {
        return SKColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }

    class func themeDarkBackgroundColor() -> SKColor {
        return SKColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }

    class func themeGrayTapCircleColor() -> SKColor {
        return SKColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.65)
    }

    class func themeDarkFontColor() -> SKColor {
        return SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
    }

    class func themeButtonTextColor() -> SKColor {
        return SKColor.whiteColor().colorWithAlphaComponent(0.85)
    }

    // Game Mode colors
    class func themeEasyModeColor() -> SKColor {
        return SKColor(red: 0.04, green: 0.63, blue: 0.54, alpha: 1)
    }

    class func themeMediumModeColor() -> SKColor {
        return SKColor(red: 0.47, green: 0.57, blue: 0.82, alpha: 1)
    }

    class func themeHardModeColor() -> SKColor {
        return SKColor(red: 0.96, green: 0.49, blue: 0.29, alpha: 1)
    }

    class func themeExpertModeColor() -> SKColor {
        return SKColor(red: 0.95, green: 0.17, blue: 0.22, alpha: 1)
    }

    class func themeHighScoreModeColor() -> SKColor {
        return SKColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    }

    // Returns the proper color for a given GameMode
    class func colorForGameMode(mode: GameMode) -> SKColor {
        if mode == GameMode.Easy {
            return SKColor.themeEasyModeColor()
        } else if mode == GameMode.Medium {
            return SKColor.themeMediumModeColor()
        } else if mode == GameMode.Hard {
            return SKColor.themeHardModeColor()
        } else if mode == GameMode.Expert {
            return SKColor.themeExpertModeColor()
        } else if mode == GameMode.HighScore {
            return SKColor.themeHighScoreModeColor()
        }

        return SKColor.clearColor()
    }
}
