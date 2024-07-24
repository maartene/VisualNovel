//
//  Shared.swift
//  VN
//
//  Created by Maarten Engels on 21/10/2020.
//

import Foundation
import InkSwift

let INK_FILE_NAME = "test"

func makeStory() -> InkStory {
    let story = InkStory()

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
    
    return story
}

