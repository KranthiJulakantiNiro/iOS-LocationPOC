//
//  WebViewController.swift
//  OurWebVIew
//
//  Created by Kranthi Kumar Julakanti on 02/05/22.
//

import UIKit
import WebKit
import CoreLocation

public class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, CLLocationManagerDelegate {
    
    let webView: WKWebView = {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let contentController = WKUserContentController()
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        configuration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: configuration)

        return webView
    }()
    
    var locationManager: CLLocationManager? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(webView)
        
        // Location Related
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        guard let url = URL(string: "https://dev.niro.money/location-poc") else {
            return
        }
        webView.load(URLRequest(url: url))
        
        // webView.customUserAgent = "iPad/Chrome/Something"
        
        // Javascript injection
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            let js = "localStorage.setItem(\"accessToken\", \"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjMzY3MTA1NC02ODhhLTRlMDktYTEwNy0wMjMwMDA4Y2U0MjgiLCJpYXQiOjE2NTE2NDIyMTUsImV4cCI6MTY1MTcyODYxNX0.BNYemAKCIlvmWrD_NpFz20pvMmMLjZ6KkAzWm7nw9S4\"); localStorage.setItem(\"refreshToken\", \"eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjMzY3MTA1NC02ODhhLTRlMDktYTEwNy0wMjMwMDA4Y2U0MjgiLCJpYXQiOjE2NTEyMzIxODMsImV4cCI6MTY1MjA5NjE4M30.o9pbJAqX5FTLaG_3i13Kuhz8yxPfbX3Acxrdmiev2gc\")"
            self.webView.evaluateJavaScript(js) { result, error in
                guard let html = result as? String, error == nil else {
                    return
                }
                print(html)
                
            }
        }
        
        self.webView.configuration.userContentController.add(self, name: "iosListener")
        
        self.webView.uiDelegate = self;
        self.webView.navigationDelegate = self;
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        self.webView.evaluateJavaScript("window.webkit.messageHandlers.iosListener.postMessage('test');", completionHandler: { (result, err) in
//            if (err != nil) {
//                // show error feedback to user.
//            }
//        })
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        print("Closed!")
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        if(message.body as! String == "capture_location") {
            print("capture_location")
            if(locationManager?.authorizationStatus == .denied) {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            } else {
                locationManager?.requestWhenInUseAuthorization()
            }
        } else if(message.body as! String == "check_phone_rooted") {
            print("check_phone_rooted")
            print("isJailBrokenBefore")
            let isJailBroken = UIDevice.current.isJailBroken
            let isSimulator = UIDevice.current.isSimulator
            print("isJailBroken")
            print(isJailBroken)
            print(isSimulator)
            if(isJailBroken) {
                // TODO show a pop up or something or call js method
            } else if(isSimulator) {
                // TODO show a pop up or something or call js method
            } else {
                // TODO show a pop up or something or call js method
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("hey")
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                    print("is available")
                }
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
