//
//  AudioPlayer.swift
//  VN
//
//  Created by Maarten Engels on 09/10/2020.
//

import Foundation
import AVFoundation
import Combine
import InkSwift

final class AudioPlayer {
    
    let tagToObserve: String
    let looping: Bool
    var cancellables = Set<AnyCancellable>()
    let player = AVQueuePlayer()
    var looper: AVPlayerLooper?
    
    init(tagToObserve: String, in story: InkStory, looping: Bool) {
        self.tagToObserve = tagToObserve
        self.looping = looping
        
        story.$currentTags.sink(receiveValue: { [weak self] tags in
            guard let strongSelf = self else {
                return
            }
            
            if let audioClipName = tags[tagToObserve] {
                print("Received tag to start audio: \(audioClipName)")
                if let url = Bundle.main.url(forResource: audioClipName, withExtension: nil) {
                    print("Found audioclip in url: \(url)")
                    let clip = AVPlayerItem(url: url)
                    
                    self?.player.removeAllItems()
                    
                    if looping {
                        self?.looper = AVPlayerLooper(player: strongSelf.player, templateItem: clip)
                    } else {
                        self?.player.insert(clip, after: nil)
                    }
                    
                    self?.player.play()
                }
                
            }
        }).store(in: &cancellables)
    }
}
