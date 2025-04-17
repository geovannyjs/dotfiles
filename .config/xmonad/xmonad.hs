import XMonad

import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.Loggers

import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP

import XMonad.Layout.ResizableTile
import XMonad.Layout.NoBorders (noBorders)

import XMonad.Prompt
import XMonad.Prompt.Shell

import Graphics.X11.ExtraTypes.XF86


gray, green, white :: String
gray = "#dedede"
green = "#88ff88"
white = "#ffffff"

main :: IO ()
main = xmonad . ewmhFullscreen . ewmh . docks . dynamicSBs barSpawner $ myConfig

myConfig = def {
  modMask = mod4Mask
  , layoutHook = layout
  , manageHook = myManageHook
  , normalBorderColor = "#444444"
  , focusedBorderColor = green
  , focusFollowsMouse = True
  , terminal = "urxvt -cd `xcwd`"
} `additionalKeys` 
  [
    ((0, xF86XK_AudioLowerVolume), spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-")
    , ((0, xF86XK_AudioMute), spawn "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    , ((0, xF86XK_AudioRaiseVolume), spawn "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+")
    , ((0, xF86XK_AudioMicMute), spawn "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
    , ((0, xF86XK_MonBrightnessDown), spawn "brightnessctl set 10%-")
    , ((0, xF86XK_MonBrightnessUp), spawn "brightnessctl set 10%+")
    , ((mod4Mask, xK_r), shellPrompt myPromptConfig)
    -- the laptop key to send video signal to HDMI-1 output is the same as WIN + p
    , ((mod4Mask, xK_p), spawn "xrandr --listactivemonitors | grep HDMI-1 >/dev/null && xrandr --output HDMI-1 --off || xrandr --output HDMI-1 --right-of eDP-1 --mode 1920x1080")
    , ((mod4Mask .|. controlMask, xK_l), spawn "slock")
    , ((mod4Mask, xK_s), unGrab *> spawn "scrot -o -s /dev/stdout | xclip -selection clipboard -target image/png")
    , ((mod4Mask .|. controlMask, xK_s), unGrab *> spawn "scrot -o -s")
    -- ResizableTile
    , ((mod4Mask, xK_a), sendMessage MirrorShrink)
    , ((mod4Mask, xK_z), sendMessage MirrorExpand)
  ]

layout = avoidStruts ( noBorders Full ||| resizableTiled ||| Mirror resizableTiled )
  where
    -- resizable tiling
    resizableTiled = ResizableTall nmaster delta ratio []
    -- number of windows in the master pane
    nmaster = 1
    -- proportion of screen occupied by master pane
    ratio = 1/2
    -- percent of screen to increment by when resizing panes
    delta = 3/100

myPromptConfig = def {
  position = Bottom
  , alwaysHighlight = True
  , bgColor = "#000000"
  , fgColor = white
  , historySize = 0
  , promptBorderWidth = 0
  , font = "xft:Hack Nerd Font Mono:size=9"
}

myXmobarPP :: PP
myXmobarPP = def {
  ppSep = xmobarColorGreen "  \xec07  "
  , ppTitleSanitize = xmobarStrip
  , ppCurrent = wrap "(" ")" . xmobarColorGreen
  , ppVisible = wrap "(" ")" . xmobarColorWhite
  , ppUrgent = red . wrap (yellow "!") (yellow "!")
  , ppOrder = \[ws, l, _, wins] -> [l, ws, wins]
  , ppExtras = [logTitles formatFocused formatUnfocused]
} where
  --formatFocused   = wrap (xmobarColorGray "[") (xmobarColorGray "]") . xmobarColorGreen . ppWindow
  --formatUnfocused = wrap (xmobarColorGray "(") (xmobarColorGray ")") . xmobarColorGray . ppWindow
  formatFocused   = xmobarColorGreen . ppWindow
  formatUnfocused = xmobarColorGray . ppWindow

  -- | Windows should have *some* title, which should not not exceed a
  -- sane length.
  ppWindow :: String -> String
  ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

  blue = xmobarColor "#0000ff" ""
  xmobarColorGreen = xmobarColor green ""
  xmobarColorGray = xmobarColor gray ""
  xmobarColorWhite = xmobarColor white ""
  yellow = xmobarColor "#f1fa8c" ""
  red = xmobarColor "#ff0000" ""

xmobar0 = statusBarPropTo "_XMONAD_LOG_0" "/home/geovanny/.cabal/bin/xmobar -x 0 /home/geovanny/.config/xmobar/xmobarrc0" (pure myXmobarPP)
xmobar1 = statusBarPropTo "_XMONAD_LOG_1" "/home/geovanny/.cabal/bin/xmobar -x 1 /home/geovanny/.config/xmobar/xmobarrc1" (pure myXmobarPP)

barSpawner :: ScreenId -> IO StatusBarConfig
barSpawner 0 = pure xmobar0
barSpawner 1 = pure xmobar1

myManageHook :: ManageHook
myManageHook = composeAll [
  className =? "Gimp" --> doCenterFloat
  , className =? "xfreerdp" --> doCenterFloat
  , isDialog --> doCenterFloat ]
