# Waypoint 📍🧭

**Offline GPS Homing Beacon & Directional Compass for Mobile (Flutter)**

Waypoint is an outdoor utility app designed to solve a simple problem: **"Where did I leave my car or trailhead, and which way do I walk to get back?"**

It works **100% offline with zero cellular data or map downloads**, calculating real-time spherical trigonometry bearings and orienting a live graphical compass arrow toward your dropped pin using device hardware sensors.

---

## ✨ Features

- 🎯 **Graphical Directional Needle**: A tactical HUD compass rotating with your phone's magnetometer while pointing directly at your target pin.
- 🚗 **One-Tap Quick Drops**: Fast action buttons to drop pins for your **Parked Car**, **Trailhead Start**, or **Campsite**.
- 📏 **Live Distance Readout**: Shows exact line-of-sight distance in Feet/Miles (Imperial) or Meters/Kilometers (Metric).
- 🟢 **Proximity Arrival Ring**: When you get within ~50 feet (15 meters) of your target, the radar glows emerald and signals arrival.
- 🗂️ **Saved Pins & Target Switching**: Keep a local history of pins with timestamps, categories, and custom notes; tap any pin to lock it as your active navigation beacon.
- 🛰️ **100% Offline & Private**: All GPS math runs directly on-device. No accounts, tracking, or cloud servers required.

---

## 📐 How the Navigation Math Works

1. **Target Bearing ($\theta$):**
   Calculates the forward azimuth from your current GPS position $(lat_1, lon_1)$ to the target pin $(lat_2, lon_2)$:
   $$\theta = \operatorname{atan2}\left(\sin(\Delta lon) \cdot \cos(lat_2),\ \cos(lat_1) \cdot \sin(lat_2) - \sin(lat_1) \cdot \cos(lat_2) \cdot \cos(\Delta lon)\right)$$

2. **Device Heading ($\psi$):**
   Monitored in real-time via the phone's internal 3-axis magnetometer sensor (`flutter_compass`).

3. **Relative Arrow Needle Angle ($\phi$):**
   $$\phi = (\theta - \psi) \pmod{360^\circ}$$
   This is rendered smoothly onto the custom-painted HUD dial.

4. **Haversine Distance ($d$):**
   Calculates the great-circle surface distance directly in meters.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0.0 or higher)
- Xcode (for iOS) or Android Studio (for Android)

### Quick Run
```bash
# Clone the repository
git clone https://github.com/<your-username>/waypoint.git
cd waypoint

# Install Flutter dependencies
flutter pub get

# Run on connected phone or simulator
flutter run
```

---

## 📱 Permissions Configured
- **iOS (`Info.plist`)**: `NSLocationWhenInUseUsageDescription`, `NSMotionUsageDescription`
- **Android (`AndroidManifest.xml`)**: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`

---

## 🛠️ Architecture
- `lib/models/`: Waypoint data structures with JSON serialization.
- `lib/services/`: Local persistent storage, location permissions & streaming, compass stream.
- `lib/utils/`: Spherical trigonometry formulas (Bearing, Haversine, Angle normalization).
- `lib/widgets/`: CustomPainter compass dial, animated arrow needle, pin cards.
- `lib/screens/`: Radar view, Pin history, Navigation shell.
