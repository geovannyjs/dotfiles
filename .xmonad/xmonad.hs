import qualified Data.Map as M

import XMonad

import qualified XMonad.Actions.Submap as SM

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName

import XMonad.Layout.Spacing

import XMonad.Util.EZConfig

import Graphics.X11.ExtraTypes.XF86

import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8


main :: IO ()
main = do
  dbus <- D.connectSession
  -- Request access to the DBus name
  D.requestName dbus (D.busName_ "org.xmonad.Log")
    [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]

  xmonad $ docks . ewmh $ def {
      borderWidth = 2
      ,focusedBorderColor = "#2172ff"
      ,focusFollowsMouse = False
      ,modMask = mod4Mask
      ,layoutHook = myLayout
      ,logHook = dynamicLogWithPP (myLogHook dbus)
      ,workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
      ,startupHook = myStartupHook
    }
    `additionalKeys` [
      ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -2%")
      ,((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
      ,((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +2%")
      ,((0, xF86XK_MonBrightnessDown), spawn "xbacklight -dec 10")
      ,((0, xF86XK_MonBrightnessUp), spawn "xbacklight -inc 10")
      ,((mod4Mask, xK_Return), spawn "urxvt -cd \"`xcwd`\"")
      ,((mod4Mask, xK_o), spawn "i3lock -c 000000")
      ,((mod4Mask, xK_p), spawn "rofi -theme ~/.config/rofi/theme.rasi -show run")
      ,((mod4Mask, xK_b), SM.submap . M.fromList $ [
        ((0, xK_t), toggleWindowSpacingEnabled >> toggleScreenSpacingEnabled)
        ,((0, xK_i), incScreenWindowSpacing 5)
        ,((0, xK_d), decScreenWindowSpacing 5)
      ])
    ]

myLayout = avoidStruts (tiled ||| Mirror tiled ||| Full)
  where
    tiled    = spacingWithEdge 5 $ Tall nmaster delta ratio
    nmaster  = 1      -- Default number of windows in the master pane
    ratio    = 1/2    -- Default proportion of screen occupied by master pane
    delta    = 3/100  -- Percent of screen to increment by when resizing panes

myStartupHook = do
  setWMName "Xmonad"
  spawn "$HOME/.config/polybar/launch.sh"

-- Override the PP values as you would otherwise, adding colors etc depending
-- on  the statusbar used
myLogHook :: D.Client -> PP
myLogHook dbus = def { 
    ppOutput = dbusOutput dbus
    ,ppCurrent = wrap ("%{B" ++ "#2172ff" ++ "} ") " %{B-}"
    ,ppHidden = wrap " " " "
    ,ppSep = " | "
    ,ppVisible = wrap ("%{F" ++ "#83a598" ++ "} ") " %{F-}"
    ,ppWsSep = ""
  }

-- Emit a DBus signal on log updates
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal objectPath interfaceName memberName) {
      D.signalBody = [D.toVariant $ UTF8.decodeString str]
    }
    D.emit dbus signal
  where
    objectPath = D.objectPath_ "/org/xmonad/Log"
    interfaceName = D.interfaceName_ "org.xmonad.Log"
    memberName = D.memberName_ "Update"
