import SwiftUI
import WebKit

struct RainDisplayView: View {
    @StateObject private var rainFlowController = RainFlowController.shared
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                RainWebView(
                    rainUrl: rainFlowController.rainCachedEndpoint ?? "",
                    rainOnURLUpdate: { rainNewURL in
                        rainFlowController.rainUpdateURL(rainNewURL)
                    }
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct RainWebView: UIViewRepresentable {
    let rainUrl: String
    let rainOnURLUpdate: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let rainConfig = WKWebViewConfiguration()
        let rainPreferences = WKWebpagePreferences()
        rainPreferences.allowsContentJavaScript = true
        rainConfig.defaultWebpagePreferences = rainPreferences
        
        rainConfig.allowsInlineMediaPlayback = true
        rainConfig.mediaTypesRequiringUserActionForPlayback = []
        rainConfig.allowsAirPlayForMediaPlayback = true
        rainConfig.allowsPictureInPictureMediaPlayback = true
        
        rainConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        let rainWebView = WKWebView(frame: .zero, configuration: rainConfig)
        rainWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        rainWebView.scrollView.backgroundColor = .black
        rainWebView.backgroundColor = .black
        rainWebView.navigationDelegate = context.coordinator
        rainWebView.uiDelegate = context.coordinator
        
        rainWebView.allowsBackForwardNavigationGestures = true
        rainWebView.scrollView.keyboardDismissMode = .interactive
        rainWebView.allowsLinkPreview = false
        
        let rainRefreshControl = UIRefreshControl()
        rainRefreshControl.tintColor = UIColor.white
        rainRefreshControl.addTarget(
            context.coordinator,
            action: #selector(RainCoordinator.rainHandleRefresh(_:)),
            for: .valueChanged
        )
        rainWebView.scrollView.refreshControl = rainRefreshControl
        rainWebView.scrollView.bounces = true
        
        context.coordinator.rainRefreshControl = rainRefreshControl
        
        if let rainCookieData = UserDefaults.standard.array(forKey: "rain_saved_cookies_v1") as? [Data] {
            for rainCookieDataItem in rainCookieData {
                if let rainCookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rainCookieDataItem) as? HTTPCookie {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(rainCookie)
                }
            }
        }
        
        if !rainUrl.isEmpty, let rainWebURL = URL(string: rainUrl) {
            let rainRequest = URLRequest(url: rainWebURL)
            rainWebView.load(rainRequest)
        }
        
        return rainWebView
    }
    
    func updateUIView(_ rainUiView: WKWebView, context: Context) {
        if !rainUrl.isEmpty {
            let rainCurrentURLString = rainUiView.url?.absoluteString ?? ""
            if rainCurrentURLString != rainUrl {
                print("🔄 [RainWebView] URL changed from '\(rainCurrentURLString)' to '\(rainUrl)' - reloading")
                if let rainWebURL = URL(string: rainUrl) {
                    let rainRequest = URLRequest(url: rainWebURL)
                    rainUiView.load(rainRequest)
                }
            }
        }
    }
    
    func makeCoordinator() -> RainCoordinator {
        RainCoordinator(self)
    }
    
    class RainCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let rainParent: RainWebView
        private weak var rainWebView: WKWebView?
        weak var rainRefreshControl: UIRefreshControl?
        
        init(_ rainParent: RainWebView) {
            self.rainParent = rainParent
            super.init()
        }
        
        @objc func rainHandleRefresh(_ rainRefreshControl: UIRefreshControl) {
            rainWebView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                rainRefreshControl.endRefreshing()
            }
        }
        
        func webView(_ rainWebView: WKWebView, didStartProvisionalNavigation rainNavigation: WKNavigation!) {
            self.rainWebView = rainWebView
        }
        
        func webView(_ rainWebView: WKWebView, didFinish rainNavigation: WKNavigation!) {
            rainRefreshControl?.endRefreshing()
            
            if let rainCurrentURL = rainWebView.url?.absoluteString {
                rainParent.rainOnURLUpdate(rainCurrentURL)
            }
            
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { rainCookies in
                let rainCookieData = rainCookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(rainCookieData, forKey: "rain_saved_cookies_v1")
            }
        }
        
        func webView(_ rainWebView: WKWebView, didFail rainNavigation: WKNavigation!, withError rainError: Error) {
            rainRefreshControl?.endRefreshing()
        }
        
        func webView(_ rainWebView: WKWebView, decidePolicyFor rainNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let rainUrl = rainNavigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let rainScheme = rainUrl.scheme?.lowercased() ?? ""
            
            if rainScheme != "http" && rainScheme != "https" {
                print("🔗 [RainWebView] Opening external URL: \(rainUrl)")
                UIApplication.shared.open(rainUrl)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ rainWebView: WKWebView, createWebViewWith rainConfiguration: WKWebViewConfiguration, for rainNavigationAction: WKNavigationAction, windowFeatures rainWindowFeatures: WKWindowFeatures) -> WKWebView? {
            if let rainUrl = rainNavigationAction.request.url {
                rainWebView.load(URLRequest(url: rainUrl))
            }
            return nil
        }
        
        func webView(_ rainWebView: WKWebView, runJavaScriptAlertPanelWithMessage rainMessage: String, initiatedByFrame rainFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let rainAlert = UIAlertController(title: nil, message: rainMessage, preferredStyle: .alert)
            rainAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let rainWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rainWindow = rainWindowScene.windows.first {
                rainWindow.rootViewController?.present(rainAlert, animated: true)
            }
        }
        
        func webView(_ rainWebView: WKWebView, runJavaScriptConfirmPanelWithMessage rainMessage: String, initiatedByFrame rainFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let rainAlert = UIAlertController(title: nil, message: rainMessage, preferredStyle: .alert)
            rainAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            rainAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let rainWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rainWindow = rainWindowScene.windows.first {
                rainWindow.rootViewController?.present(rainAlert, animated: true)
            }
        }
    }
}
