
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
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized && AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
                decisionHandler(.grant)
            } else {
                AVCaptureDevice.requestAccess(for: .video) { videoGranted in
                    AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                        if videoGranted && audioGranted {
                            decisionHandler(.grant)
                        } else {
                            print("request denied")
                            decisionHandler(.deny)
                        }
                    }
                }
            }
        }
        
    }


}

struct ContentView: View {
    @State private var urlString = "https://video-practo.netlify.app/"
    @State private var cameraPermissionGranted = false
    @State private var audioPermissionGranted = false

    var body: some View {
        NavigationView {
            WebView(urlString: urlString)
        }
        .onAppear {
            checkAndRequestPermissions()
        }
    }

    private func checkAndRequestPermissions() {
//        checkCameraPermission()
//        checkAudioPermission()
    }

   
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
//
//private func checkCameraPermission() {
////        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
////            requestCameraPermission()
//    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
//        cameraPermissionGranted = true
//        print("has camera per")
//    } else {
//        requestCameraPermission()
//        print("Camera permission not granted")
//    }
//}
//
//private func requestCameraPermission() {
//    print("requesting Camera per")
//    AVCaptureDevice.requestAccess(for: .video) { granted in
//        DispatchQueue.main.async {
//            cameraPermissionGranted = granted
//            UserDefaults.standard.set(granted, forKey: "CameraPermissionGranted")
//        }
//    }
//}
//
//private func checkAudioPermission() {
////        if AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined {
////            requestAudioPermission()
//    if AVCaptureDevice.authorizationStatus(for: .audio) == .authorized {
//        audioPermissionGranted = true
//    } else {
//        requestAudioPermission()
//        print("Audio permission not granted")
//    }
//}
//
//private func requestAudioPermission() {
//    print("requesting audio per")
//    AVCaptureDevice.requestAccess(for: .audio) { granted in
//        DispatchQueue.main.async {
//            audioPermissionGranted = granted
//            UserDefaults.standard.set(granted, forKey: "AudioPermissionGranted")
//        }
//
//}
// }
