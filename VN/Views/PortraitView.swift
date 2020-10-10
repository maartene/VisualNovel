//
//  PortraitView.swift
//  VN
//
//  Created by Maarten Engels on 06/10/2020.
//

import SwiftUI

struct PortraitView: View {
    @ObservedObject var story: InkStory
    
    let tagToObserve: String
    
    var portraitName: String? {
        story.currentTags[tagToObserve]
    }
    
    var body: some View {
        if portraitName != nil {
            Image(portraitName!)
                .shadow(radius: 10, x: 5, y: 5)
                .transition(.slide)
                
        }
    }
}

struct PortraitView_Previews: PreviewProvider {
    static var previews: some View {
        PortraitView(story: InkStory(), tagToObserve: "portraitLeft")
    }
}
