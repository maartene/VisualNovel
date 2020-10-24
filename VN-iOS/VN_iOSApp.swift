//
//  VN_iOSApp.swift
//  VN-iOS
//
//  Created by Maarten Engels on 11/10/2020.
//

import SwiftUI

@main
struct VN_iOSApp: App {
    let story: InkStory
    let backgroundMusicPlayer: AudioPlayer
    let sfxPlayer: AudioPlayer
    let ambiancePlayer: AudioPlayer
    
    init() {
        story = InkStory()
        backgroundMusicPlayer = AudioPlayer(tagToObserve: "bgMusic", in: story, looping: true)
        sfxPlayer = AudioPlayer(tagToObserve: "sfx", in: story, looping: false)
        ambiancePlayer = AudioPlayer(tagToObserve: "ambiance", in: story, looping: true)
        
        story.retainTags = ["portraitLeft", "portraitRight", "background"]
        story.loadStory(json: story.inkStoryJson(fileName: INK_FILE_NAME, fileExtension: "json"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(story: story)
        }
    }
}
