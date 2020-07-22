//
//  MusicPlayer.swift
//  FirstAppByYen
//
//  Created by YenChang on 2020/7/16.
//  Copyright © 2020 YenChang. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI
import WebKit
import XCDYouTubeKit

class MusicPlayer: NSObject {
    static let instance = MusicPlayer()

    // object to loop music
    var looper: AVPlayerLooper?
    let player = AVQueuePlayer()
    
    private override init () {
        
    }
    
    func addMusicToPlayer(videoId: String) {
        var targetURL: String!
        targetURL = "https://www.youtube.com/watch?v=\(videoId)"
        let url = URL(string: targetURL)!
        var streamUrl = URL(string: "")
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId, completionHandler: {(video, error) in
            if error == nil {
                streamUrl = video?.streamURL
                let item = AVPlayerItem(url: streamUrl!)
                self.player.insert(item, after: self.player.items().last)
            }
        })
    }
    
    // play music with videoId
    func playMusic(videoId: String) {
        var targetURL: String!
        targetURL = "https://www.youtube.com/watch?v=\(videoId)"
        
        let url = URL(string: targetURL)!
        var streamUrl = URL(string: "")
        /*URLSession.shared.dataTask(with: url) { (datatmp, response, error) in
           if let error = error {
               print(error.localizedDescription)
               return
           }
           guard (response as? HTTPURLResponse) != nil else {
               print(response as Any)
               return
           }
           
           if let data = datatmp,
               let string = String(data: data, encoding: .utf8) {
                let dic = self.getDictionnaryFrom(string: string)
                let url = URL(string: dic)
                let item = AVPlayerItem(url: url!)
                self.player.replaceCurrentItem(with: item)
                self.player.play()
           }
           }.resume()*/
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId, completionHandler: {(video, error) in
            if error == nil {
                streamUrl = video?.streamURL
                let item = AVPlayerItem(url: streamUrl!)
                self.player.replaceCurrentItem(with: item)
                self.player.play()
            }
        })

    }
    
    // reset AVQueuePlayer
    func resetPlayer() {
        player.pause()
        player.removeAllItems()
    }
    
    // get and parse html from youtube
    func getDictionnaryFrom(string: String) -> String {
        let parts = string.components(separatedBy: "url=")
        for part in parts{
            var keyval = part.components(separatedBy: "\\\"},{")
            if (keyval.count > 1 && keyval[0].starts(with: "https")){
                keyval[0] = keyval[0].replacingOccurrences(of: "\\/", with: "/")
                return keyval[0].removingPercentEncoding!
            }
        }
        return ""
    }
    
}

struct WebView: UIViewRepresentable {

    typealias UIViewType = WKWebView
    
    var videoId = ""
    
    var embedVideoHtml: String {
        return """
        <!DOCTYPE html>
        <html>
        <body>
        <div id="player"></div>
        <script>
        // Load the IFrame Player API code asynchronously.
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/player_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        // Replace the 'ytplayer' element with an <iframe> and
        // YouTube player after the API code downloads.
        var player;
        function onYouTubePlayerAPIReady() {
          player = new YT.Player('player', {
            playerVars: { 'autoplay': 1, 'controls': 0, 'playinline': 1 },
            height: '0',
            width: '0',
            videoId: '\(videoId)',
            events: {
                'onReady': onPlayerReady,
                'onStateChange': onChange
            }
          });
          player.playVideo();
        }
        
        function onPlayerReady(event) {
            event.target.playVideo();
            player.playVideo();
        }
        
        function onChange(event) {
            event.target.playVideo();
            player.playVideo();
        }
        </script>
        </body>
        </html>
        """
    }
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: /*CGRect(x: 0, y: 0, width: 375, height: 300)*/.zero, configuration: config)
 
        var targetUrl: String!
        //targetUrl = "https://www.youtube.com/embed/\(videoId)?playsinline=1&autoplay=1"
        
        //targetUrl = "https://www.youtube.com/embed/\(videoId)?loop1&playlist=\(videoId)&playsinline=1&autoplay=1"
        targetUrl = "https://www.youtube.com/watch?v=\(videoId)"
        webView.loadHTMLString(embedVideoHtml, baseURL: URL(string: targetUrl))
        if let url = URL(string: targetUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
    }
    
    
}
