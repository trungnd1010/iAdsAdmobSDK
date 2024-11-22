//
//  MonetCoreSDK_Dependency_AdsNativeManagerProtocolAdsNativeManager.swift
//  ExampleCoreSDK
//
//  Created by Trung Nguyễn on 14/11/2023.
//
import UIKit
import GoogleMobileAds
import iAdsCoreSDK
import iComponentsSDK
import iTrackingSDK


public class iAdsGamSDK_NativeManager: NSObject, iAdsCoreSDK_NativeProtocol {
    
    private override init() {}
    
    @iComponentsSDK_Atomic
    var completionLoad: ((Result<Void, Error>) -> Void)?
    
    @iComponentsSDK_Atomic
    public var isLoading: Bool = false
    
    public var isHasAds: Bool = false

    private var nativeAdLoader: GADAdLoader? = nil
    
    private var placement: String = ""
    private var priority: String = ""
    private var adNetwork: String = "AdGam"
    private var adsId: String = ""
    
    private var nativeAd: GADNativeAd? = nil
    private var dateStartLoad: Date = Date()
    
    public static
    func make() -> iAdsCoreSDK_NativeProtocol {
        return iAdsGamSDK_NativeManager()
    }
    
    //  "ca-app-pub-3940256099942544/4411468910"
    public func loadAds(vc: UIViewController,
                        adsId: String,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        if self.isLoading {
            completion(.failure(iAdsGamSDK_Error.adsIdIsLoading))
            return
        }
        
        self.dateStartLoad = Date()
        self.completionLoad = completion
        self.isLoading = true
        self.adsId = adsId
        
        nativeAdLoader = GADAdLoader(
            adUnitID: adsId,
            rootViewController: vc,
            adTypes: [.native],
            options: nil)
        nativeAdLoader?.delegate = self
        nativeAdLoader?.load(GADRequest())
    }
    
    public func showAds(containerView: UIView,
                        nativeAdmobView: UIView?,
                        nativeMaxView: UIView? = nil,
                        placement    : String,
                        priority     : Int,
                        completion   : @escaping (Result<Void, Error>) -> Void) {
        self.isHasAds = false
        self.priority = "\(priority)"
        self.placement = placement
        
        guard let nativeData = self.nativeAd,
            let nativeView = nativeAdmobView as? BaseGADNativeAdView else {
            completion(.failure(iAdsGamSDK_Error.noAdsToShow))
            return
        }
        
        containerView.iComponentsSDK_removeAllSubviews()
        nativeView.configAd(nativeAd: nativeData)
        containerView.iComponentsSDK_addSubView(subView: nativeView)
        completion(.success(()))
    }
}

extension iAdsGamSDK_NativeManager: GADAdLoaderDelegate, GADNativeAdLoaderDelegate, GADNativeAdDelegate  {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        
       
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .loaded,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
                                       priority: "",
                                       recall_ad: .no)
        isHasAds = true
        self.nativeAd = nativeAd
        self.nativeAd?.delegate = self
        
        nativeAd.paidEventHandler = { [weak self] adValue in
            guard let self else { return }
            self.adNetwork = nativeAd.responseInfo.loadedAdNetworkResponseInfo?.adSourceName ?? "unknown"
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
        completionLoad?(.success(()))
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        isLoading = false
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .load_failed,
                                       ad_unit_name: adsId,
                                       ad_action: .load,
                                       script_name: .load_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: error.localizedDescription,
                                       time: "\(Date().timeIntervalSince1970 - dateStartLoad.timeIntervalSince1970)",
                                       priority: "",
                                       recall_ad: .no)
        completionLoad?(.failure(error))
    }
    
    public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .clicked,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .impression,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .showed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
    
    public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        iAdsCoreSDK_AdTrack().tracking(placement: self.placement,
                                       ad_status: .closed,
                                       ad_unit_name: adsId,
                                       ad_action: .show,
                                       script_name: .show_xx,
                                       ad_network: adNetwork,
                                       ad_format: .Native,
                                       sub_ad_format: .native,
                                       error_code: "",
                                       message: "",
                                       time: "",
                                       priority: "",
                                       recall_ad: .no)
    }
}

//@objc open
//class BaseGADNativeAdView: GADNativeAdView {
//    public override func awakeFromNib() {
//        super.awakeFromNib()
//        
//    }
//    
//    override public init(frame: CGRect) {
//        super.init(frame: frame)
//        _loadViewFromNib()
//    }
//
//    required public init?(coder: NSCoder) {
//        super.init(coder: coder)
//        _loadViewFromNib()
//    }
//    
//    func configAd(nativeAd: GADNativeAd) {
//        (self.headlineView as? UILabel)?.text = nativeAd.headline
//        //        (self.headlineView as? UILabel)?.adjustsFontSizeToFitWidth = true
//        // These assets are not guaranteed to be present. Check that they are before
//        // showing or hiding them.
//        (self.bodyView as? UILabel)?.text   = nativeAd.body
//        //        (self.bodyView as? UILabel)?.adjustsFontSizeToFitWidth = true
//        self.bodyView?.isHidden = nativeAd.body == nil
//        (self.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//        self.callToActionView?.isHidden = nativeAd.callToAction == nil
//        (self.iconView as? UIImageView)?.image = nativeAd.icon?.image
//        self.iconView?.isHidden = nativeAd.icon == nil
//        (self.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
//        self.starRatingView?.isHidden = nativeAd.starRating == nil
//        (self.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        self.advertiserView?.isHidden = nativeAd.advertiser == nil
//        self.callToActionView?.isUserInteractionEnabled = false
//        self.nativeAd = nativeAd
//    }
//    
//    func _loadViewFromNib() {
//        let nib = UINib(nibName: iComponentsSDK_fullClassName, bundle: .main)
//        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
//        addSubview(nibView)
//        nibView.translatesAutoresizingMaskIntoConstraints = false
//        nibView.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        nibView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        nibView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        nibView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        sendSubviewToBack(nibView)
//    }
//    
//    
//    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
//        guard let rating = starRating?.doubleValue else {
//            return nil
//        }
//        if rating >= 5 {
//            return UIImage(named: "stars_5")
//        } else if rating >= 4.5 {
//            return UIImage(named: "stars_4_5")
//        } else if rating >= 4 {
//            return UIImage(named: "stars_4")
//        } else if rating >= 3.5 {
//            return UIImage(named: "stars_3_5")
//        } else {
//            return nil
//        }
//    }
//}
