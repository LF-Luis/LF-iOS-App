# Debugging

This folder contains files used to debug this app.

## Design Note to Follow
If you are going to add another module, like UserTesting.swift, that should NEVER be deployed, then encapsulate all
working logic in a few functions (e.g.: `setUpUserStateManaging(...)`) that can then be commented out when not
in use. This way the app won't even compile when these flags are set.

### Using Compiler Falgs `D <flag_name>`
To use either  `-D NO_BEACON_TESTING` or `-D NO_WEB_API_TESTING` you need to add them under **Build Settings** -> 
**Swift Compiler - Custom Flags**, write it in the "Other Swift Flags" "Debug" box.
This way, it will only run when scheme is set to Debug (which it is set so by deafult).

##  NoBeaconTesting.swift `-D NO_BEACON_TESTING`
This module is used to test the app without needing to have BLE Beacons around, i.e. the (UUID, major, minor)
data tuple that would normally be picked up from the beacons is harcoded. 

#### How to use UserTesting.swift:
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

##  NoWebAPITesting.swift `-D NO_WEB_API_TESTING`
Test app without having to make any web API calls. Because web API calls are not made, there is no need to 
have beacons nearby as they will not be searched for. This mode is most useful when testing UI changes.
Because the iPhone's Bluetooth is no longer needed, you can run this on Xcode iPhone simulator.
