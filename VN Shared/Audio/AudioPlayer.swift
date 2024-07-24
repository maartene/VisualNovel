//
//  AudioPlayer.swift
//  VN
//
//  Created by Maarten Engels on 09/10/2020.
//

import Foundation
import AVFoundation
import Combine
import AVFoundation
import Combine

final class AudioPlayer {
    
    let tagToObserve: String
    let looping: Bool
    var cancellables = Set<AnyCancellable>()
    let player = AVQueuePlayer()
    var looper: AVPlayerLooper?
    var currentItem: AVPlayerItem?
    
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
                    
                    // Stop and remove the current item if it exists
                    strongSelf.player.pause()
                    if let currentItem = strongSelf.currentItem {
                        strongSelf.player.remove(currentItem)
                    }
                    
                    let newItem = AVPlayerItem(url: url)
                    
                    if strongSelf.looping {
                        // Remove the previous looper if it exists
                        strongSelf.looper?.disableLooping()
                        strongSelf.looper = AVPlayerLooper(player: strongSelf.player, templateItem: newItem)
                    } else {
                        strongSelf.player.insert(newItem, after: nil)
                    }
                    
                    strongSelf.currentItem = newItem
                    strongSelf.player.play()
                }
            }
        }).store(in: &cancellables)
    }
}

class AudioManager: ObservableObject {
    private let engine = AVAudioEngine()
    private var players: [String: AVAudioPlayerNode] = [:]
    private var audioFiles: [String: AVAudioFile] = [:]
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSession()
    }

    private func setupSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func preloadAllM4AAudio() {
        guard let resourcePath = Bundle.main.resourcePath else {
            print("Failed to get resource path")
            return
        }

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: resourcePath), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let m4aFiles = fileURLs.filter { $0.pathExtension == "m4a" }

            for fileURL in m4aFiles {
                let filename = fileURL.lastPathComponent
                preloadAudio(from: fileURL, withName: filename)
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
    }

    private func preloadAudio(from url: URL, withName name: String) {
        do {
            let file = try AVAudioFile(forReading: url)
            audioFiles[name] = file

            let player = AVAudioPlayerNode()
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
            players[name] = player

            print("Preloaded audio: \(name)")
        } catch {
            print("Error preloading audio \(name): \(error)")
        }
    }

    func playAudio(named filename: String, looping: Bool = false) {
        guard let player = players[filename], let file = audioFiles[filename] else {
            print("Audio not preloaded: \(filename)")
            return
        }

        if !engine.isRunning {
            do {
                try engine.start()
            } catch {
                print("Error starting audio engine: \(error)")
                return
            }
        }

        player.stop()

        if looping {
            do {
                let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
                try file.read(into: buffer!)
                player.scheduleBuffer(buffer!, at: nil, options: .loops)
            } catch {
                print("Error setting up audio loop: \(error)")
                return
            }
        } else {
            player.scheduleFile(file, at: nil)
        }

        player.play()
    }

    func stopAudio(named filename: String) {
        players[filename]?.stop()
    }

    func stopAllAudio() {
        players.values.forEach { $0.stop() }
    }

    func setVolume(_ volume: Float, for filename: String) {
        players[filename]?.volume = volume
    }

    func observeStoryAudioTags(in story: InkStory) {
        story.$currentTags
            .sink { [weak self] tags in
                if let bgMusic = tags["bgMusic"] {
                    self?.playAudio(named: bgMusic, looping: true)
                }
                if let sfx = tags["sfx"] {
                    self?.playAudio(named: sfx)
                }
                if let ambiance = tags["ambiance"] {
                    self?.playAudio(named: ambiance, looping: true)
                }
            }
            .store(in: &cancellables)
    }
}
