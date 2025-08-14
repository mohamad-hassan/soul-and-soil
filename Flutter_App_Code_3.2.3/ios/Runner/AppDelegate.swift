import UIKit
import Flutter
import Firebase
import AppTrackingTransparency 
import GoogleMobileAds

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }

    // Disables Publisher first-party ID
      GADMobileAds.sharedInstance().requestConfiguration.setPublisherFirstPartyIDEnabled(false)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        let urlString = url.absoluteString
        return true
    }

  override func applicationDidBecomeActive(_ application: UIApplication) {        
        if #available(iOS 15.0, *) {
           ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
           // Tracking authorization completed. Start loading ads here.
           // loadAd 
           })
        }
       }
  }
class AppLinks {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return handleDeepLink(url: url)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            return handleDeepLink(url: url)
        }
        return false
    }

    private func handleDeepLink(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        if let urlPattern = components.path.split(separator: "/").last {
            print("URL pattern: \(urlPattern)")
            return true
        }

        return false
    }

}