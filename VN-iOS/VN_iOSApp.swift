//
//  VN_iOSApp.swift
//  VN-iOS
//
//  Created by Maarten Engels on 11/10/2020.
//

import SwiftUI

@main
struct VNApp: App {
    let story: InkStory
//    let backgroundMusicPlayer: AudioPlayer
    let sfxPlayer: AudioPlayer
    let ambiancePlayer: AudioPlayer
    let audioManager: AudioManager
    
    init() {
//        registerFonts()   Add this line
        
        story = InkStory()
        audioManager = AudioManager()
           
        // Preload all .m4a files
        audioManager.preloadAllM4AAudio()
        
        // Set up audio tag observation
        audioManager.observeStoryAudioTags(in: story)
        
//        backgroundMusicPlayer = AudioPlayer(tagToObserve: "bgMusic", in: story, looping: true)
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
