//
//  VN_iOSApp.swift
//  VN-iOS
//
//  Created by Maarten Engels on 11/10/2020.
//

import SwiftUI
import InkSwift

@main
struct VN_iOSApp: App {
    let story = makeStory()
    let backgroundMusicPlayer: AudioPlayer
    let sfxPlayer: AudioPlayer
    let ambiancePlayer: AudioPlayer
    
    init() {
        backgroundMusicPlayer = AudioPlayer(tagToObserve: "bgMusic", in: story, looping: true)
        sfxPlayer = AudioPlayer(tagToObserve: "sfx", in: story, looping: false)
        ambiancePlayer = AudioPlayer(tagToObserve: "ambiance", in: story, looping: true)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(story: story)
        }
    }
}
