import Foundation

struct RainURLConstructor {
    
    private static let rainBaseURL = "https://coupleofglass.com/cpk5yKDm"
    
    static func rainBuildURL(
        rainAppsFlyerUID: String,
        rainConversionData: [AnyHashable: Any] = [:]
    ) -> String {
        guard var rainComponents = URLComponents(string: rainBaseURL) else {
            return rainBaseURL
        }
        
        var rainQueryItems: [URLQueryItem] = []
        
        let rainGclid = rainExtractValue(from: rainConversionData, rainKeys: ["gclid", "af_gclid"])
        let rainGbraid = rainExtractValue(from: rainConversionData, rainKeys: ["gbraid", "af_gbraid"])
        let rainGadid = rainExtractValue(from: rainConversionData, rainKeys: ["gadid", "af_gadid", "adgroup_id"])
        let rainReffer = rainExtractValue(from: rainConversionData, rainKeys: ["reffer", "referrer", "af_referrer", "install_referrer"])
        
        rainQueryItems.append(URLQueryItem(name: "gclid", value: rainGclid))
        rainQueryItems.append(URLQueryItem(name: "gbraid", value: rainGbraid))
        rainQueryItems.append(URLQueryItem(name: "gadid", value: rainGadid))
        rainQueryItems.append(URLQueryItem(name: "reffer", value: rainReffer))
        rainQueryItems.append(URLQueryItem(name: "appsflyerId", value: rainAppsFlyerUID))
        
        let rainAfAdId = rainExtractValue(from: rainConversionData, rainKeys: ["af_ad_id", "ad_id", "af_ad"])
        let rainCampaignId = rainExtractValue(from: rainConversionData, rainKeys: ["campaign_id", "af_campaign_id"])
        let rainSourceAppId = rainExtractValue(from: rainConversionData, rainKeys: ["source_app_id", "af_source_app_id"])
        let rainCampaign = rainExtractValue(from: rainConversionData, rainKeys: ["campaign", "c", "af_c"])
        let rainAfAd = rainExtractValue(from: rainConversionData, rainKeys: ["af_ad", "ad"])
        let rainAfAdset = rainExtractValue(from: rainConversionData, rainKeys: ["af_adset", "adset"])
        let rainAfAdsetId = rainExtractValue(from: rainConversionData, rainKeys: ["af_adset_id", "adset_id"])
        let rainNetwork = rainExtractValue(from: rainConversionData, rainKeys: ["network", "af_network", "media_source", "pid"])
        
        rainQueryItems.append(URLQueryItem(name: "af_ad_id", value: rainAfAdId))
        rainQueryItems.append(URLQueryItem(name: "campaign_id", value: rainCampaignId))
        rainQueryItems.append(URLQueryItem(name: "source_app_id", value: rainSourceAppId))
        rainQueryItems.append(URLQueryItem(name: "campaign", value: rainCampaign))
        rainQueryItems.append(URLQueryItem(name: "af_ad", value: rainAfAd))
        rainQueryItems.append(URLQueryItem(name: "af_adset", value: rainAfAdset))
        rainQueryItems.append(URLQueryItem(name: "af_adset_id", value: rainAfAdsetId))
        rainQueryItems.append(URLQueryItem(name: "network", value: rainNetwork))
        
        let rainGeo = Locale.current.region?.identifier ?? ""
        let rainDevice = rainGetDeviceModel()
        
        rainQueryItems.append(URLQueryItem(name: "geo", value: rainGeo))
        rainQueryItems.append(URLQueryItem(name: "device", value: rainDevice))
        
        rainComponents.queryItems = rainQueryItems
        
        guard let rainFinalURL = rainComponents.url?.absoluteString else {
            return rainBaseURL
        }
        
        print("🔗 [RainURLConstructor] Built URL with \(rainQueryItems.count) parameters")
        return rainFinalURL
    }
    
    private static func rainExtractValue(from rainData: [AnyHashable: Any], rainKeys: [String]) -> String {
        for rainKey in rainKeys {
            if let rainValue = rainData[rainKey] {
                let rainStringValue = String(describing: rainValue)
                if !rainStringValue.isEmpty && rainStringValue != "null" && rainStringValue != "<null>" {
                    return rainStringValue
                }
            }
        }
        return ""
    }
    
    private static func rainGetDeviceModel() -> String {
        var rainSystemInfo = utsname()
        uname(&rainSystemInfo)
        let rainMachineMirror = Mirror(reflecting: rainSystemInfo.machine)
        let rainIdentifier = rainMachineMirror.children.reduce("") { rainIdentifier, rainElement in
            guard let rainValue = rainElement.value as? Int8, rainValue != 0 else { return rainIdentifier }
            return rainIdentifier + String(UnicodeScalar(UInt8(rainValue)))
        }
        return rainIdentifier
    }
}
