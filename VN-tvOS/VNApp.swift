//
//  VNApp.swift
//  VN
//
//  Created by Maarten Engels on 03/10/2020.
//

import SwiftUI

@main
struct VNApp: App {
    let story: InkStory
    let backgroundMusicPlayer: AudioPlayer
    let sfxPlayer: AudioPlayer
    let foleyPlayer: AudioPlayer
    
    init() {
        story = InkStory()
        backgroundMusicPlayer = AudioPlayer(tagToObserve: "bgMusic", in: story, looping: true)
        sfxPlayer = AudioPlayer(tagToObserve: "sfx", in: story, looping: false)
        foleyPlayer = AudioPlayer(tagToObserve: "foley", in: story, looping: true)
        
        story.retainTags = ["portraitLeft", "portraitRight", "background"]
        story.loadStory(json: story.inkStoryJson(fileName: "story.ink", fileExtension: "json"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(story: story)
        }
    }
}
