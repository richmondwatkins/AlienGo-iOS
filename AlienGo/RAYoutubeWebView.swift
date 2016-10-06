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

class RAYoutubeWebView: UIView {

    let webView: UIWebView = UIWebView()
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
        
//        for (UIView *view in self.webView.scrollView.subviews) {
//            if ([view isKindOfClass:[UIImageView class]]) {
//                view.hidden = YES;
//            }
//        }
  
        self.addSubview(webView)
        
        let webViewTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RAYoutubeWebView.didTapWebView))
        webViewTapGesture.numberOfTapsRequired = 1
        webViewTapGesture.delegate = self
        
        self.webView.addGestureRecognizer(webViewTapGesture)
    }
    
    func didTapWebView() {
       
        self.delegate?.didSelectPlay()
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
        
        if embedUrlString.contains("youtube") || embedUrlString.contains("youtu.be") {
            embededHTML = youtubeHTMLEmbed(embedUrlString: embedUrlString)
        } else if embedUrlString.contains("streamable") {
            embededHTML  = streamabledHTMLEmbed(streamableURL: embedUrlString)
        }
        //TODO: need to handle this format https://youtu.be/CtWirGxV7Q8"
        
        //Streamable
        //<div style="width: 100%; height: 0px; position: relative; padding-bottom: 53.587%;"><iframe src="https://streamable.com/e/kqop" frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling="no" style="width: 100%; height: 100%; position: absolute;"></iframe></div>

        //<iframe width="560" height="315" src="https://www.youtube.com/embed/q63h59hFcX0" frameborder="0" allowfullscreen></iframe>
        
        if embededHTML == nil {
            print(embedUrlString)
            //TODO: remove before release
            abort()
        }
        
        self.webView.loadHTMLString(embededHTML, baseURL: nil)
        
        self.webView.stringByEvaluatingJavaScript(from: "document.body.style.backgroundColor = 'black';")
    }
    
    private func streamabledHTMLEmbed(streamableURL: String) -> String {
        return "<div style=\"width: 100%; height: 0px; position: relative; padding-bottom: 53.587%;\"><iframe src=\"\(streamableURL)\" frameborder=\"0\" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling=\"no\" style=\"width: 100%; height: 100%; position: absolute;\"></iframe></div>"
    }
    
    private func youtubeHTMLEmbed(embedUrlString: String) -> String {
        let youtubeStopPlayerApiScript: String = "<script> function stopPlayer() { document.getElementById('player').contentWindow.postMessage('{\"event\":\"command\",\"func\":\"' + 'pauseVideo' + '\",\"args\":\"\"}', '*');} </script>";
        let youtubeStartPlayerApiScript: String = "<script> function startPlayer() { document.getElementById('player').contentWindow.postMessage('{\"event\":\"command\",\"func\":\"' + 'playVideo' + '\",\"args\":\"\"}', '*');} </script>";
        
        //TODO: Add support for more url types and services
        let embededHTML = "<html><body> \(youtubeStopPlayerApiScript) \(youtubeStartPlayerApiScript) <style> body,html,iframe { margin: 0px } </style><iframe id=\"player\" src=\"\(embedUrlString)?playsinline=1&enablejsapi=1&version=3&playerapiid=ytplayer&modestbranding=1&showinfo=0&wmode=transparent\" width=\"\(self.frame.width)\" height=\"\(self.frame.height)\" frameborder=\"0\" allowfullscreen></iframe></body></html>"
        
        return embededHTML
    }
    
    func stopVideo() {
        
        self.webView.stringByEvaluatingJavaScript(from: "stopPlayer()");
    }
    
    func playVideo() {
        
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
        
        self.webView.stringByEvaluatingJavaScript(from: "document.body.style.backgroundColor = 'black';")
        webView.scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
}
