//
//  MonetCoreSDK_Dependency_AdsRewardedManagerProtocolAdsRewardedManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import GoogleMobileAds
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsGamSDK_RewardedManager: NSObject, iAdsCoreSDK_RewardedProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false
    
    private var rewardedAd: GADRewardedAd? = nil
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdGam"
    private var adsId: String = ""
    private var dateStartLoad: Double = Date().timeIntervalSince1970
    
    var didEarn: Bool = false
    
    public static
    func make() -> iAdsCoreSDK_RewardedProtocol {
        return iAdsGamSDK_RewardedManager()
    }
    
    //  "ca-app-pub-3940256099942544/4411468910"
    public func loadAds(adsId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsGamSDK_Error.adsIdIsLoading))
            return
        }
        
        self.dateStartLoad = Date().timeIntervalSince1970
        self.isLoading = true
        self.adsId = adsId
        let request = GAMRequest()
        
        GADRewardedAd.load(withAdUnitID: adsId,
                           request: request,
                           completionHandler: {  [weak self] ad, error in
            self?.isLoading = false
            if let error = error {
                
                iAdsCoreSDK_AdTrack().tracking(placement: self?.placement ?? "",
                                               ad_status: .load_failed,
                                               ad_unit_name: adsId,
                                               ad_action: .load,
                                               script_name: .load_xx,
                                               ad_network: self?.adNetwork ?? "",
                                               ad_format: .Rewarded_Video,
                                               sub_ad_format: .rewarded_inter,
                                               error_code: String(error.code),
                                               message: error.localizedDescription,
                                               time: iAdsCoreSDK_AdTrack().getElapsedTime(startTime: self?.dateStartLoad ?? 0),
                                               priority: "",
                                               recall_ad: .no)
                
                completion(.failure(error))
                return
            }
            self?.rewardedAd = ad
            self?.isHasAds = true
            
            iAdsCoreSDK_AdTrack().tracking(placement: self?.placement ?? "",
                                           ad_status: .loaded,
                                           ad_unit_name: adsId,
                                           ad_action: .load,
                                           script_name: .load_xx,
                                           ad_network: self?.adNetwork ?? "",
                                           ad_format: .Rewarded_Video,
                                           sub_ad_format: .rewarded_inter,
                                           error_code: "",
                                           message: "",
                                           time: iAdsCoreSDK_AdTrack().getElapsedTime(startTime: self?.dateStartLoad ?? 0),
                                           priority: "",
                                           recall_ad: .no)
            
            completion(.success(()))
        }
        )
    }
    
    public func showAds(vc        : UIViewController,
                        placement : String,
                        priority  : Int,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        self.didEarn = false
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        if let rewardedAd {
            self.adNetwork = rewardedAd.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "unknown"
            
            rewardedAd.paidEventHandler = { [weak self] adValue in
                guard let self
                else { return }
               
                iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADGAM,
                                              currency: adValue.currencyCode,
                                              value: Double(truncating: adValue.value),
                                              ad_unit_name: adsId,
                                              ad_network: adNetwork,
                                              ad_format: .Rewarded_Video,
                                              sub_ad_format: .rewarded_inter,
                                              placement: placement,
                                              ad_id: "",
                                              source: .AdSourceAdjust_AdMob)
                
            }
            
            completionShow = completion
            rewardedAd.fullScreenContentDelegate = self
            rewardedAd.present(fromRootViewController: vc) { [weak self] in
                self?.didEarn = true
            }
        } else {
            completion(.failure(iAdsGamSDK_Error.noAdsToShow))
        }
    }
}

//GADFullScreenContentDelegate
extension iAdsGamSDK_RewardedManager: GADFullScreenContentDelegate {
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .show_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: String(error.code),
                                       message: error.localizedDescription,
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        completionShow?(.failure(error))
    }
    
    public func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
    }
    
    public func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //Not used
    }
    
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .closed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Rewarded_Video,
                                       sub_ad_format: .rewarded_inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        if didEarn {
            completionShow?(.success(()))
        } else {
            completionShow?(.failure(iAdsCoreSDK_Error.closeNoReward))
        }
    }
}
