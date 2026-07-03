import CoreLocation
import Flutter
import NetworkExtension
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let wifiInfoHandler = WifiInfoHandler()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "NovaWifiInfo") {
      let channel = FlutterMethodChannel(
        name: "com.novaheronix.wifimanager/nfc",
        binaryMessenger: registrar.messenger()
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.wifiInfoHandler.handle(call, result: result)
      }
    }
  }
}

/// Handles the `getCurrentWifiSsid` platform call. iOS only exposes the current
/// SSID (via NEHotspotNetwork.fetchCurrent) once the user has granted Location
/// ("When in Use") permission, so we request it on demand, then fetch.
final class WifiInfoHandler: NSObject, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  private var pending: FlutterResult?

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getCurrentWifiSsid" else {
      result(FlutterMethodNotImplemented)
      return
    }

    locationManager.delegate = self
    let status: CLAuthorizationStatus
    if #available(iOS 14.0, *) {
      status = locationManager.authorizationStatus
    } else {
      status = CLLocationManager.authorizationStatus()
    }

    switch status {
    case .authorizedWhenInUse, .authorizedAlways:
      fetchSsid(result)
    case .notDetermined:
      pending = result
      locationManager.requestWhenInUseAuthorization()
    default:
      result(nil) // denied / restricted
    }
  }

  private func fetchSsid(_ result: @escaping FlutterResult) {
    guard #available(iOS 14.0, *) else {
      result(nil)
      return
    }
    NEHotspotNetwork.fetchCurrent { network in
      DispatchQueue.main.async { result(network?.ssid) }
    }
  }

  // iOS 14+ authorization callback.
  @available(iOS 14.0, *)
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard let result = pending else { return }
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      pending = nil
      fetchSsid(result)
    case .notDetermined:
      break // wait for the user's choice
    default:
      pending = nil
      result(nil)
    }
  }
}
