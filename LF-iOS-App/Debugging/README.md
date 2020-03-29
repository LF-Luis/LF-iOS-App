# Debugging

This folder contains files used to debug this app.

## Using Compiler Falgs `-D <flag_name>`
To use either  `-D NO_BEACON_TESTING` or `-D NO_WEB_API_TESTING` you need to add them under **Build Settings** -> **Swift Compiler - Custom Flags**, write it in the "Other Swift Flags" "Debug" box.
This way, it will only run when scheme is set to Debug (which it is set so by deafult in simulator and Xcode-to-phone installation).

##  NoWebAPITesting.swift `-D NO_WEB_API_TESTING`
Test app without using web API calls.  
Data in the app will be populated with fake data, therefore beacons are not needed either.  

With this flag enabled, beacons are not searched for therefore a physical phone's bluetooth is not needed; this allows you to see your changes (with fake data) in the Xcode phone simulator.

##  NoBeaconTesting.swift `-D NO_BEACON_TESTING`
This module is used to test the app without needing to have BLE Beacons around, i.e. the (UUID, major, minor)
data tuple that would normally be picked up from the beacons is harcoded.  

Note that this mode currently assumes that the web APIs will be working.

#### How to use NoBeaconTesting.swift:
In the HomeCollectionVC class, setUpUserStateManaging() function, run
userStateManager.runTestNoBeacons(). E.g.:
```swift
@objc private func setUpUserStateManaging() {
    userStateManager = UserStateManager()  
    userStateManager.delegate = self  
    userStateManager.runTestNoBeacons()
    ...
}
```

## Design Note to Follow
If you are adding another test module, try to encapsulate as much logic for it in a single file, like it is done here for NoWebAPITesting.swift and NoBeaconTesting.swift, to ease debugging of a module.
