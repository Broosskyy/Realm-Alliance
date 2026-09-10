# V1.7 MOBILE DEVICE QA

## 720×1600
Check:
- top resources all fit on one row
- Settings icon reachable
- Monster not clipped
- Home Wheel CTA visible
- bottom Home/Rad/Dorf buttons fully visible
- Settings bottom controls and close button visible
- Building Upgrade modal fully reachable

## 1080×1920
This remains the master/reference layout.

## 1080×2400
Check:
- extra height does not create huge dead zones
- Monster remains central
- Wheel remains visually dominant
- Village cards remain grouped and easy to scan

## Input abuse tests
- spam Monster during Defeat
- spam Spin during animation
- spam Continue on Reward
- tap Bottom Nav while modal is open
- open/close Settings repeatedly
- open building then hammer Upgrade
- background app mid-Wheel and resume

Expected:
No duplicate reward, no double spend, no stuck overlay, no hidden navigation.
