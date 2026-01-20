import UIKit
import AppsFlyerLib
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        rainConfigureAppsFlyer()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(rainStartAppsFlyer),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
    }
    
    private func rainConfigureAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = "KSxshPBTbwE3hhDAapJJ4m"
        
        AppsFlyerLib.shared().appleAppID = "6757008025"
        
        AppsFlyerLib.shared().delegate = self
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        print("📱 [AppDelegate] AppsFlyer configured")
    }
    
    private static var rainWasStarted = false
    
    @objc private func rainStartAppsFlyer() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] rainStatus in
                print("📱 [AppDelegate] Tracking authorization: \(rainStatus.rawValue)")
                self?.rainLaunchAppsFlyer()
            }
        } else {
            rainLaunchAppsFlyer()
        }
    }
    
    private func rainLaunchAppsFlyer() {
        guard !Self.rainWasStarted else { return }
        Self.rainWasStarted = true
        
        AppsFlyerLib.shared().start()
        
        let rainUid = AppsFlyerLib.shared().getAppsFlyerUID()
        print("📱 [AppDelegate] AppsFlyer started, UID: \(rainUid)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("✅ [AppDelegate] AppsFlyer conversion data received")
        
        let rainAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID: \(rainAppsFlyerUID), length: \(rainAppsFlyerUID.count)")
        
        RainFlowController.shared.rainUpdateAppsFlyerData(
            rainUid: rainAppsFlyerUID,
            rainConversionData: conversionInfo
        )
    }
    
    func onConversionDataFail(_ error: Error) {
        let rainErrorDescription = error.localizedDescription
        if rainErrorDescription.contains("mismatched af_sig") {
            print("⚠️ [AppDelegate] AppsFlyer conversion data not available (normal for subsequent launches): \(rainErrorDescription)")
        } else {
            print("❌ [AppDelegate] AppsFlyer conversion data failed: \(rainErrorDescription)")
        }
        
        let rainAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID (fallback): \(rainAppsFlyerUID), length: \(rainAppsFlyerUID.count)")
        
        if !rainAppsFlyerUID.isEmpty {
            RainFlowController.shared.rainUpdateAppsFlyerData(rainUid: rainAppsFlyerUID, rainConversionData: [:])
        }
    }
}
