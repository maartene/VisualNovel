//
//  ContentView.swift
//  VN
//
//  Created by Maarten Engels on 03/10/2020.
//

import SwiftUI
struct ContentView: View {
    @ObservedObject var story: InkStory
    
    var body: some View {
        ZStack {
            // Background
            if story.currentTags["background"] != nil {
                Image(story.currentTags["background"]!)
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
                    .padding()
                    .background(VisualEffectView(effect: UIBlurEffect(style: .light)).opacity(0.5))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(story: InkStory())
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
