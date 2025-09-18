# Location Sender App

## Overview
This is the **Sender App** in a real-time location tracking system.  
It allows a user to **share their device location** with others in real-time. The location is pushed to **Firebase Realtime Database**.

---

## Features
- Generate a **unique Sender ID** for each user.
- Request **location permissions** (foreground and background on Android).
- Start and stop **real-time location sharing**.
- Send location updates to **Firebase Realtime Database** every few seconds.
- Show **last shared location** in the app UI.

---

## Tech Stack
- Flutter
- Firebase Realtime Database
- Geolocator (for location)
- Flutter Foreground Task (for background location updates)
- Provider (state management)
