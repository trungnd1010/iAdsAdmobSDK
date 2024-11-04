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
    func setup() {
        GADMobileAds.sharedInstance().start()
    }
}

