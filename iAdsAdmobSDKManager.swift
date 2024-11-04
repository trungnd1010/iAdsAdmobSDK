//
//  iAdsAdmobSDKManager.swift
//  iAdsAdmobSDK
//
//  Created by Nguyễn Trung on 4/11/24.
//

import GoogleMobileAds

public class iAdsAdmobSDKManager {
    public static let shared = iAdsAdmobSDKManager()
    private init() {}
    
    @MainActor
    func setup(isTestAds: Bool) {
        GADMobileAds.sharedInstance().start()
        if isTestAds, let currentIDFV = UIDevice.current.identifierForVendor?.uuidString {
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [currentIDFV ]
        }
    }
}

