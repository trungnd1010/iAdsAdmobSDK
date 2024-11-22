//
//  MonetCoreSDK_Dependency_AdsIntertitialManagerProtocolAdsIntertitialManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import GoogleMobileAds
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsGamSDK_InterManager: NSObject, iAdsCoreSDK_IntertitialProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionShow: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false
    
    private var interstitialAd: GAMInterstitialAd? = nil
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdGam"
    private var adsId: String = ""
    
    private var dateStartLoad: Date = Date()
    
    public static
    func make() -> iAdsCoreSDK_IntertitialProtocol {
        return iAdsGamSDK_InterManager()
    }
    
    //  "ca-app-pub-3940256099942544/4411468910"
    public func loadAds(adsId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsGamSDK_Error.adsIdIsLoading))
            return
        }
        self.dateStartLoad = Date()
        self.isLoading = true
        self.adsId = adsId
        let request = GAMRequest()
        GAMInterstitialAd.load(withAdManagerAdUnitID: adsId,
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
                                               ad_format: .Interstitial,
                                               sub_ad_format: .inter,
                                               error_code: "",
                                               message: error.localizedDescription,
                                               time: "\(Date().timeIntervalSince1970 - (self?.dateStartLoad.timeIntervalSince1970 ?? 0))",
                                               priority: "",
                                               recall_ad: .no)
                
                completion(.failure(error))
                return
            }
            self?.interstitialAd = ad
            self?.isHasAds = true
            
            iAdsCoreSDK_AdTrack().tracking(placement: self?.placement ?? "",
                                           ad_status: .loaded,
                                           ad_unit_name: adsId,
                                           ad_action: .load,
                                           script_name: .load_xx,
                                           ad_network: self?.adNetwork ?? "",
                                           ad_format: .Interstitial,
                                           sub_ad_format: .inter,
                                           error_code: "",
                                           message: "",
                                           time: "\(Date().timeIntervalSince1970 - (self?.dateStartLoad.timeIntervalSince1970 ?? 0))",
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
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        if let interstitialAd {
            self.adNetwork = interstitialAd.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "unknown"
            
            interstitialAd.paidEventHandler = { [weak self] adValue in
                guard let self
                else { return }
               
                iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADGAM,
                                              currency: adValue.currencyCode,
                                              value: Double(truncating: adValue.value),
                                              ad_unit_name: adsId,
                                              ad_network: adNetwork,
                                              ad_format: .Interstitial,
                                              sub_ad_format: .inter,
                                              placement: placement,
                                              ad_id: "",
                                              source: .AdSourceAdjust_AdMob)
                
            }
            
            completionShow = completion
            interstitialAd.fullScreenContentDelegate = self
            interstitialAd.present(fromRootViewController: vc)
        } else {
            completion(.failure(iAdsGamSDK_Error.noAdsToShow))
        }
    }
}

//GADFullScreenContentDelegate
extension iAdsGamSDK_InterManager: GADFullScreenContentDelegate {
    public func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
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
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
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
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
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
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
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
                                       ad_format: .Interstitial,
                                       sub_ad_format: .inter,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: priority,
                                       recall_ad: .no)
        completionShow?(.success(()))
    }
}
