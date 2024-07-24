//
//  ContentView.swift
//  VN
//
//  Created by Maarten Engels on 03/10/2020.
//

import SwiftUI
import InkSwift

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension View {

    public func background() -> some View {
        #if os(macOS)
        return self.background(Color.gray.opacity(0.5))
        #else
        return self.background(VisualEffectView(effect: UIBlurEffect(style: .light)).opacity(0.5))
        #endif
    }

}

struct ContentView: View {
    @ObservedObject var story: InkStory
    
    var body: some View {
        ZStack {
            Color.black
            // Background
            GeometryReader { proxy in
                if story.currentTags["background"] != nil {
                    Image(story.currentTags["background"]!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        
                }
            }
            
            
            // Portraits
            HStack(alignment: .bottom) {
                PortraitView(story: story, tagToObserve: "portraitLeft")
                Spacer()
                PortraitView(story: story, tagToObserve: "portraitRight")
            }.offset(x: 0, y: 16).frame(maxWidth: .infinity)
            
            // Text and options
            VStack {
                Spacer()
                InkTextView(story: story)
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding().background()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(story: InkStory())
    }
}

#if os(tvOS) || os(iOS)
public struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
#endif
