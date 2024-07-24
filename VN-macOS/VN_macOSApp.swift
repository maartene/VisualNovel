//
//  VN_macOSApp.swift
//  VN-macOS
//
//  Created by Maarten Engels on 13/10/2020.
//

import SwiftUI
import InkSwift

@main
struct VN_macOSApp: App {
    let story: InkStory
    let backgroundMusicPlayer: AudioPlayer
    let sfxPlayer: AudioPlayer
    let ambiancePlayer: AudioPlayer
    
    init() {
        story = InkStory()
        
        guard let storyInkURL = Bundle.main.url(forResource: INK_FILE_NAME, withExtension: "ink") else {
             fatalError("Unable to locate Ink story")
        }
        
        do {
            let storyInkString = try String(contentsOf: storyInkURL)
            try story.loadStory(ink: storyInkString)
        } catch {
            fatalError("Error occured when loading and compiling story: \(error)")
        }
        
        story.retainTags = ["portraitLeft", "portraitRight", "background"]
        backgroundMusicPlayer = AudioPlayer(tagToObserve: "bgMusic", in: story, looping: true)
        sfxPlayer = AudioPlayer(tagToObserve: "sfx", in: story, looping: false)
        ambiancePlayer = AudioPlayer(tagToObserve: "ambiance", in: story, looping: true)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(story: story)
                .frame(width: 1280, height: 720)
        }
    }
}
