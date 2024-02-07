//
//  ContentView.swift
//  WebView
//
//  Created by Ronald Maharabam on 05/02/24.
//
import SwiftUI
import WebKit
import AVFoundation

struct WebView: UIViewRepresentable {
    var urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: configuration)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        } else {
            print("ios version not available")
        }
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator


        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
    }


}

struct ContentView: View {
    @State private var urlString = "https://video-practo.netlify.app/"
//    @State private var urlString = "http://localhost:3000"
    @State private var cameraPermissionGranted = false
    @State private var audioPermissionGranted = false

    var body: some View {
        NavigationView {
            WebView(urlString: urlString)
//                .navigationBarTitle("Web View Example")
//                .navigationBarItems(trailing: Button("Reload") {
//                    urlString = "https://www.google.com"
//                })
        }.onAppear{
            checkAndRequestPermissions()
        }
    }
    private func requestCameraAndAudioPermissions() {
       AVCaptureDevice.requestAccess(for: .video) { grantedVideo in
           AVCaptureDevice.requestAccess(for: .audio) { grantedAudio in
               DispatchQueue.main.async {
                   cameraPermissionGranted = true
                   audioPermissionGranted = true
               }
           }
       }
    }
    private func checkAndRequestPermissions() {
        if !UserDefaults.standard.bool(forKey: "CameraPermissionGranted") {
            AVCaptureDevice.requestAccess(for: .video) { grantedVideo in
                if grantedVideo {
                    cameraPermissionGranted = true
                    UserDefaults.standard.set(true, forKey: "CameraPermissionGranted")
                } else {
                    print("Camera permission not granted")
                }
            }
        } else {
            cameraPermissionGranted = true
        }

        if !UserDefaults.standard.bool(forKey: "AudioPermissionGranted") {
            AVCaptureDevice.requestAccess(for: .audio) { grantedAudio in
                if grantedAudio {
                    audioPermissionGranted = true
                    UserDefaults.standard.set(true, forKey: "AudioPermissionGranted")
                } else {
                    print("Audio permission not granted")
                }
            }
        } else {
            audioPermissionGranted = true
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
