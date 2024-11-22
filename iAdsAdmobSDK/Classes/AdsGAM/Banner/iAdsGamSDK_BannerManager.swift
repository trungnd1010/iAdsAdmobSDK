//
//  MonetCoreSDK_Dependency_AdsBannerManagerProtocolAdsBannerManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import UIKit
import GoogleMobileAds
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsGamSDK_BannerManager: NSObject, iAdsCoreSDK_BannerProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false

    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdGam"
    private var adsId: String = ""
    
    private var sub_ad_format = iAdsCoreSDK_AdTrack.AdTrackSubAdFormat.banner_inline
    private var paid_ad_format = iAdsCoreSDK_PaidAd.PaidAdSubAdFormat.banner_inline
    
    private var bannerView: GAMBannerView? = nil
    private var dateStartLoad: Date = Date()
    
    public static
    func make() -> iAdsCoreSDK_BannerProtocol {
        return iAdsGamSDK_BannerManager()
    }
    
    //  "ca-app-pub-3940256099942544/4411468910"
    public func loadAds(vc: UIViewController,
                        collapsible: String?,
                        isMrec: Bool?,
                        adsId: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsAdmobSDK_Error.adsIdIsLoading))
            return
        }
        self.dateStartLoad = Date()
        self.completionLoad = completion
        self.isLoading = true
        self.adsId = adsId
        
        if (isMrec ?? false) {
            sub_ad_format = .mrec
            paid_ad_format = .mrec
        }
        
        if (collapsible ?? "") != "" {
            sub_ad_format = .banner_collapsible
            paid_ad_format = .banner_collapsible
        }
        
        
        DispatchQueue.main.async {
            self.bannerView = GAMBannerView()
            self.bannerView?.adSize = GADAdSizeBanner
            self.bannerView?.adUnitID = adsId
            self.bannerView?.delegate = self
            self.bannerView?.rootViewController = vc
            
            let request = GADRequest()
            if let collapsible = collapsible {
                let extras = GADExtras()
                self.bannerView?.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.width)
                extras.additionalParameters = ["collapsible" : collapsible]
                request.register(extras)
            }
            
            self.bannerView?.load(request)
        }
    }
    
    public func showAds(containerView: UIView,
                        placement    : String,
                        priority     : Int,
                        completion   : @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        
        guard let bannerView = self.bannerView else {
            completion(.failure(iAdsAdmobSDK_Error.noAdsToShow))
            return
        }
        
        containerView.iComponentsSDK_removeAllSubviews()
        containerView.iComponentsSDK_addSubView(subView: bannerView)
        completion(.success(()))
    }
}

extension iAdsGamSDK_BannerManager: GADBannerViewDelegate  {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: "",
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
                                       priority: "",
                                       recall_ad: .no)
        isHasAds = true
        
        bannerView.paidEventHandler = { [weak self] adValue in
            guard let self else { return }
            self.adNetwork = bannerView.responseInfo?.loadedAdNetworkResponseInfo?.adSourceName ?? "unknown"
            iAdsCoreSDK_PaidAd().tracking(ad_platform: .ADGAM,
                                          currency: adValue.currencyCode,
                                          value: Double(truncating: adValue.value),
                                          ad_unit_name: adsId,
                                          ad_network: adNetwork,
                                          ad_format: .Banner,
                                          sub_ad_format: paid_ad_format,
                                          placement: placement,
                                          ad_id: "",
                                          source: .AdSourceAdjust_AdMob)
        }
        completionLoad?(.success(()))
        completionLoad = nil
    }
    
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: error.localizedDescription,
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.failure(error))
        completionLoad = nil
    }
    
    public func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .closed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Banner,
                                       sub_ad_format: sub_ad_format,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
}

