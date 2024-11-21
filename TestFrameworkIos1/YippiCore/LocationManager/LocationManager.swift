//
//  LocationManager.swift
//  Yippi
//
//  Created by Kit Foong on 08/11/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation

import CoreLocation
import UIKit

class LocationManager: NSObject {
    static let shared = LocationManager()
    private var locationManager = CLLocationManager()
    private var geoCoder = CLGeocoder()
    private let operationQueue = OperationQueue()
    
    var onLocationUpdate: EmptyClosure?
    var location: CLLocation? = nil
    var locationCoordinate: CLLocationCoordinate2D? = nil
    var latitude : Double?
    var longitude : Double?
    var shouldPromptAlert: Bool = false
    
    override init() {
        super.init()
        
        //Pause the operation queue because
        // we don't know if we have location permissions yet
        operationQueue.isSuspended = true
        if !TSRootViewController.share.shouldHideViewByAppVersion() {
            locationManager.delegate = self
        }
    }
    
    func setupLocationService() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 100
        //locationManager.allowsBackgroundLocationUpdates = true
        //locationManager.pausesLocationUpdatesAutomatically = false
        //locationManager.allowDeferredLocationUpdates(untilTraveled: 5, timeout: 60000)
        self.startMonitorLocation()
        
        if getLocationPermissionStatus() == .denied || getLocationPermissionStatus() == .restricted {
            showLocationAlert()
        }
    }
    
    func startMonitorLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitorLocation() {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    /// 清除位置数据
    func clearLocationData() {
         location = nil
         locationCoordinate = nil
         latitude = nil
         longitude = nil
    }

    func getLocationPermissionStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func showLocationAlert() {
        if shouldPromptAlert {
            shouldPromptAlert = false
            
            let alert = UIAlertController(title: "rw_location_limited_permission_fail".localized, message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
            UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
    
    ///Checks the status of the location permission
    /// and adds the callback block to the queue to run when finished checking
    /// NOTE: Anything done in the UI should be enclosed in `DispatchQueue.main.async {}`
    func runLocationBlock(callback: @escaping () -> ()) {
        
        //Get the current authorization status
        let authState = CLLocationManager.authorizationStatus()
        
        //If we have permissions, start executing the commands immediately
        // otherwise request permission
        if (authState == .authorizedAlways || authState == .authorizedWhenInUse) {
            self.operationQueue.isSuspended = false
        } else {
            //Request permission
            locationManager.requestAlwaysAuthorization()
        }
        
        //Create a closure with the callback function so we can add it to the operationQueue
        let block = { callback() }
        
        //Add block to the queue to be executed asynchronously
        self.operationQueue.addOperation(block)
    }
    
    func presetCountryCode() {
        // If Contry Code cache was nil
        if UserDefaults.selectedCountryCode == nil {
            if let location = location {
                // If able to get location
                geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
                    guard let currentLocPlacemark = placemarks?.first else { return }
                    printIfDebug(currentLocPlacemark.isoCountryCode ?? "No country code found")
                    let countries = self.getCountries()
                    
                    if let country = countries.first(where: { $0.code == currentLocPlacemark.isoCountryCode} ) {
                        UserDefaults.selectedCountryCode = country.code
                    } else {
                        // Preset to Malaysia country code
                        UserDefaults.selectedCountryCode = "MY"
                    }
                }
            } else {
                // Preset to Malaysia country code
                UserDefaults.selectedCountryCode = "MY"
            }
        }
    }
    
    func getCountries() -> [CountryEntity] {
        return CountriesStoreManager().fetch()
    }
    
    func getCountryCode() -> String {
        return UserDefaults.selectedCountryCode ?? "MY"
    }
    
    func isChina() -> Bool {
        return getCountryCode() == "CN"
    }
}

extension LocationManager: CLLocationManagerDelegate  {
    ///When the user presses the allow/don't allow buttons on the popup dialogue
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //If we're authorized to use location services, run all operations in the queue
        // otherwise if we were denied access, cancel the operations
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.operationQueue.isSuspended = false
            startMonitorLocation()  // 确保位置服务被重新启动

        } else if status == .denied || status == .restricted {
            self.operationQueue.cancelAllOperations()
            clearLocationData()
            self.showLocationAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        locationCoordinate = manager.location?.coordinate
        latitude = locationCoordinate?.latitude
        longitude = locationCoordinate?.longitude
        locationManager.stopUpdatingLocation()
        
        if let location = location {
            Device.appLoction = location
        }

        onLocationUpdate?()
    }
}
