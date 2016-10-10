//
//  ACYoutubeWebView.swift
//  ApptlyCore
//
//  Created by Richmond Watkins on 1/19/16.
//  Copyright © 2016 Richmond Watkins. All rights reserved.
//

import UIKit

protocol RAYoutubeWebDelegate: class {
    func didSelectPlay()
}

enum VideoState {
    case play, stop, loading
}

class RAYoutubeWebView: UIView {

    let webView: UIWebView = UIWebView()
    var state: VideoState = .loading
    var urlString: String! {
        didSet {
            loadVideo(embedUrlString: urlString)
        }
    }
    weak var delegate: RAYoutubeWebDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
         sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
         sharedInit()
    }
    
    func sharedInit() {
        
        self.webView.delegate = self
        self.webView.allowsInlineMediaPlayback = true
        self.webView.scrollView.isScrollEnabled = false
  
        self.addSubview(webView)
        
        let webViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RAYoutubeWebView.didTapWebView))
        webViewTapGesture.numberOfTapsRequired = 1
        webViewTapGesture.delegate = self
        
        self.webView.addGestureRecognizer(webViewTapGesture)
    }
    
    func didTapWebView() {
        switch state {
        case .play:
            stopVideo()
            break
        case .stop:
            playVideo()
            break
        case .loading:
            playVideo()
            break
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = self.bounds
        
        if let urlString = urlString {
            loadVideo(embedUrlString: urlString)
        }        
    }
    
    private func loadVideo(embedUrlString: String) {
        var embededHTML: String!
        
        if urlIsYoutube() {
            embededHTML = youtubeHTMLEmbed(embedUrlString: embedUrlString)
        } else if urlIsVine() {
            embededHTML = vineEmbed(embedUrlString: embedUrlString)
        } else if urlIsVidMe() {
            embededHTML = vidmeHTMLEmbed(embedUrlString: embedUrlString)
        } else if urlIsStreamable() {
            embededHTML  = streamabledHTMLEmbed(streamableURL: embedUrlString)
        }
        
        //Streamable
        //<div style="width: 100%; height: 0px; position: relative; padding-bottom: 53.587%;"><iframe src="https://streamable.com/e/kqop" frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling="no" style="width: 100%; height: 100%; position: absolute;"></iframe></div>

        //<iframe width="560" height="315" src="https://www.youtube.com/embed/q63h59hFcX0" frameborder="0" allowfullscreen></iframe>
        
        //Vine 
        //https://vine.co/v/5gAphDzxlYt
        // <iframe src="https://vine.co/v/5gAphDzxlYt/embed/simple" width="600" height="600" frameborder="0"></iframe><script src="https://platform.vine.co/static/scripts/embed.js"></script>
        
        if embededHTML == nil {
            print(embedUrlString)
            //TODO: remove before release
            abort()
        }
        
        self.webView.loadHTMLString(embededHTML, baseURL: nil)
        
        self.webView.stringByEvaluatingJavaScript(from: "document.body.style.backgroundColor = 'black';")
    }
    
    fileprivate func urlIsYoutube() -> Bool {
        return urlString.contains("youtube") || urlString.contains("youtu.be")
    }
    
    fileprivate func urlIsVine() -> Bool {
        return urlString.contains("vine")
    }
    
    fileprivate func urlIsVidMe() -> Bool {
        return urlString.contains("vid.me")
    }
    
    fileprivate func urlIsStreamable() -> Bool {
        return urlString.contains("streamable")
    }
    
    private func streamabledHTMLEmbed(streamableURL: String) -> String {
        return "<div style=\"width: 100%; height: 0px; position: relative; padding-bottom: 53.587%;\"><iframe src=\"\(streamableURL)\" frameborder=\"0\" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling=\"no\" style=\"width: 100%; height: 100%; position: absolute;\"></iframe></div>"
    }
    
    private func vidmeHTMLEmbed(embedUrlString: String) -> String {
        let components = NSURLComponents(string: embedUrlString)!
        let originalPath = components.path!
        
         var newPath = ""
        if embedUrlString.contains("vid.me") && originalPath.characters.count == 5 {
            newPath = originalPath.replacingOccurrences(of: "/", with: "/e/")
        }
        
        let newUrl = "\(components.scheme!)://vid.me\(newPath)"
        
        return "<iframe src=\"\(newUrl)\" width=\"720\" height=\"554\" frameborder=\"0\" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling=\"no\"></iframe>"
    }
    
    private func vineEmbed(embedUrlString: String) -> String {
        let components = NSURLComponents(string: embedUrlString)!
        let originalPath = components.path!
        var embedUrlString = embedUrlString
        
        if embedUrlString.contains("vine.co") && originalPath.contains("/v/") {
            embedUrlString += "/embed/simple"
        }
        
        //<iframe src="https://vine.co/v/5gAphDzxlYt/embed/simple" width="600" height="600" frameborder="0"></iframe><script src="https://platform.vine.co/static/scripts/embed.js"></script>
        
        let embedHtml = "<iframe src=\"\(embedUrlString)\" width=\"\(self.frame.width)\" height=\"\(self.frame.height)\" frameborder=\"0\"></iframe><script src=\"https://platform.vine.co/static/scripts/embed.js\"></script>"
        
        return embedHtml
    }
    
    private func youtubeHTMLEmbed(embedUrlString: String) -> String {
        let components = NSURLComponents(string: embedUrlString)!
        let originalPath = components.path!
        
        var newPath = ""
        if embedUrlString.contains("youtu.be") && originalPath.characters.count == 12 {
            newPath = originalPath.replacingOccurrences(of: "/", with: "/embed/")
        } else if embedUrlString.contains("youtube.com") && originalPath.contains("/v/") {
            newPath = originalPath.replacingOccurrences(of: "/v/", with: "/embed/")
        } else if embedUrlString.contains("youtube.com") && originalPath.contains("/watch") && components.queryItems?.first?.name == "v" {
            newPath = "\(originalPath.replacingOccurrences(of: "/watch", with: "/embed/"))\(components.queryItems?.first?.value ?? "")"
        }
        
        let newUrl = "\(components.scheme!)://youtube.com\(newPath)"
        
        let youtubeStopPlayerApiScript: String = "<script> function stopPlayer() { document.getElementById('player').contentWindow.postMessage('{\"event\":\"command\",\"func\":\"' + 'pauseVideo' + '\",\"args\":\"\"}', '*');} </script>";
        let youtubeStartPlayerApiScript: String = "<script> function startPlayer() { document.getElementById('player').contentWindow.postMessage('{\"event\":\"command\",\"func\":\"' + 'playVideo' + '\",\"args\":\"\"}', '*');}</script>";
        
        //TODO: Add support for more url types and services
        let embededHTML = "<html><body> \(youtubeStopPlayerApiScript) \(youtubeStartPlayerApiScript) <style> body,html,iframe { margin: 0px } </style><iframe id=\"player\" src=\"\(newUrl)?playsinline=1&enablejsapi=1&version=3&playerapiid=ytplayer&modestbranding=1&showinfo=0&wmode=transparent\" width=\"\(self.frame.width)\" height=\"\(self.frame.height)\" frameborder=\"0\" allowfullscreen></iframe></body></html>"
        
        return embededHTML
    }
    
    func stopVideo() {
        state = .stop
        self.webView.stringByEvaluatingJavaScript(from: "stopPlayer()");
    }
    
    func playVideo() {
        state = .play
        self.webView.stringByEvaluatingJavaScript(from: "startPlayer()");
    }
}

extension RAYoutubeWebView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

extension RAYoutubeWebView: UIWebViewDelegate {
    
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if urlIsYoutube() {
            playVideo()
        }
        
        self.webView.stringByEvaluatingJavaScript(from: "document.body.style.backgroundColor = 'black';")
        webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
}
