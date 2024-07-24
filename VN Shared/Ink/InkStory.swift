//
//  InkStory.swift
//  InkSwift
//
//  Created by Maarten Engels on 13/04/2020.
//  Copyright © 2020 thedreamweb. All rights reserved.
//

import Foundation
import JavaScriptCore
import Combine


class InkStory: ObservableObject {
    struct SaveState: Codable {
        let jsonState: String
        let currentTags: [String: String]
    }
    
    var jsContext: JSContext! = JSContext()
    
    // by default, we retain the "IMAGE" tag. This way, an image persists between story parts, until a different image is set.
    // if you don't want this behaviour, set inkStory.retainTags = []
    var retainTags = ["IMAGE"]
    
    init() {
        currentText = ""
        canContinue = false
        options = [Option]()
        currentTags = [String: String]()
        globalTags = [String: String]()
        oberservedVariables = [String: JSValue]()
        currentErrors = [String]()
    }
    
    func inkStoryJson(fileName: String, fileExtension: String?) -> String {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            fatalError("Could not find ink story file.")
        }
        
        do {
            return try String(contentsOf: url)
        } catch {
            print(error)
        }
        return ""
    }
    
    func loadStory(json: String) {
          guard let jsInkUrl = Bundle.main.url(forResource: "ink", withExtension: "js") else {
              fatalError("Failed to locate InkJS in bundle.")
          }

          guard let data = try? Data(contentsOf: jsInkUrl) else {
              fatalError("Failed to load InkJS from bundle.")
          }

          guard let jsInkUrlString = String(data: data, encoding: .utf8) else {
              fatalError("Unable to parse InkJS as string.")
          }

          jsContext.exceptionHandler = { context, exception in
              print("JS Exception: \(exception?.toString() ?? "unknown error")")
          }

          print("Evaluating ink.js")
          jsContext.evaluateScript(jsInkUrlString)

          // Check if inkjs is defined
          if jsContext.evaluateScript("typeof inkjs").toString() == "undefined" {
              print("Error: inkjs is not defined. Check if ink.js is loaded correctly.")
              return
          }

          print("Creating story with JSON")
          let createStoryScript = """
          try {
              if (typeof inkjs === 'undefined') {
                  throw new Error('inkjs is undefined');
              }
              if (typeof inkjs.Story === 'undefined') {
                  throw new Error('inkjs.Story is undefined');
              }
              var storyJson = \(json);
              story = new inkjs.Story(storyJson);
              console.log('Story created successfully');
          } catch(e) {
              console.error('Error creating story:', e.message);
              throw e;
          }
          """
          jsContext.evaluateScript(createStoryScript)

          // Verify that story was created
          if jsContext.evaluateScript("typeof story").toString() == "undefined" {
              print("Error: story object was not created. Check the JSON and ink.js compatibility.")
              return
          }

          print("Continuing story")
          continueStory()

          print("Finished loading InkStory.")
      }



    @Published var options: [Option]
    @Published var globalTags: [String: String]
    @Published var currentErrors: [String]
    
    // these need to be persisted
    @Published var currentTags: [String: String]
    @Published var oberservedVariables: [String: JSValue]
    
    @Published private(set) var currentText: String = ""
    private(set) var canContinue: Bool = false {
        willSet {
            if newValue != canContinue {
                objectWillChange.send()
            }
        }
    }
    
    func refreshState() {
        // Update properties
        objectWillChange.send()

        currentText = jsContext.evaluateScript("story.currentText;")?.toString() ?? ""
        refreshOptions()
        parseTags()
        refreshObservedVariables()
        refreshErrors()
        _ = _storyCanContinue()
    }
    private let jsQueue = DispatchQueue(label: "com.yourapp.jsqueue", qos: .userInitiated)
    
    func executeJS(_ script: String, completion: @escaping (JSValue?) -> Void) {
        jsQueue.async { [weak self] in
            guard let self = self else { return }
            let result = self.jsContext.evaluateScript(script)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    @discardableResult
    func continueStory() {
        executeJS("story.Continue();") { [weak self] _ in
            self?.refreshState()
        }
    }
    
    /// Returns the current story text (bridging InkJS 'currentText' variable)
    /// # This function has side effects: it sets the 'currentText' variable.
    private func _storyCurrentText() -> String {
        let s = jsContext.evaluateScript("story.currentText;")?.toString() ?? ""
        currentText = s
        return s
    }
    
    /// Returns whether the story can respond to a 'continue' trigger (bridging InkJS 'canContinue' variable)
    /// # This function has side effects: it sets the 'canContinue' variable
    private func _storyCanContinue() -> Bool {
        let c = jsContext.evaluateScript("story.canContinue;").toBool()
        canContinue = c
        return c
    }
    
    private func refreshOptions() {
        //options.removeAll()
        let textOptions = jsContext.evaluateScript("story.currentChoices;")?.toArray() ?? []
        
        options = textOptions.compactMap { option in
            if let dict = option as? Dictionary<String, Any> {
                if let index = dict["index"] as? NSNumber, let text = dict["text"] as? String {
                    return Option(index: index.intValue, text: text)
                }
            }
            return nil
        }
        
        /*for option in textOptions {
            if let dict = option as? Dictionary<String, Any> {
                if let index = dict["index"] as? NSNumber, let text = dict["text"] as? String {
                    options.append(Option(index: index.intValue, text: text))
                }
            }
        }*/
    }
    
    private func refreshErrors() {
        let errors = jsContext.evaluateScript("story.currentErrors;")?.toArray() ?? []
        currentErrors = errors.compactMap { element in
            element as? String
        }
    }
    
    func chooseChoiceIndex(_ index: Int, afterChoiceAction: (() -> Void)? = nil) {
        jsContext.evaluateScript("story.ChooseChoiceIndex(\(index));")
        //options.removeAll()
        continueStory()
        afterChoiceAction?()
    }
    
    private func clearTags() {
        for element in currentTags {
            if retainTags.contains(element.key) {
                //print("Retaining: \(element)")
            } else {
                currentTags.removeValue(forKey: element.key)
            }
        }
    }
    
    private func parseTags() {
        let gts = jsContext.evaluateScript("story.globalTags;")?.toArray() ?? []
        
        for tag in gts {
            if let tagValue = tag as? String {
                let splits = tagValue.split(separator: ":")
                if splits.count > 1 {
                    globalTags[String(splits[0])] = String(splits[1])
                } else {
                    globalTags[String(splits[0])] = String(splits[0])
                }
            }
        }
        //print("Global tags: \(globalTags)")
        
        clearTags()
        let cts = jsContext.evaluateScript("story.currentTags;")?.toArray() ?? []
        for tag in cts {
            if let tagValue = tag as? String {
                let splits = tagValue.split(separator: ":")
                if splits.count > 1 {
                    currentTags[String(splits[0])] = String(splits[1]).trimmingCharacters(in: .whitespaces)
                } else {
                    currentTags[String(splits[0])] = String(splits[0])
                }
            }
        }
        //print("Current tags: \(currentTags)")
    }
    
    func stateToJSON() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let json = jsContext.evaluateScript("story.state.toJson();")?.toString() ?? ""
        let state = SaveState(jsonState: json, currentTags: currentTags)
        do {
            let data = try encoder.encode(state)
            let string = String(data: data, encoding: .utf8) ?? ""
            print("Succesfully created save state JSON.")
            return string
        } catch {
            print("Error while saving: ", error)
            return ""
        }
    }
    
    func loadState(_ jsonDataString: String) {
        let jsonData = jsonDataString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let state = try decoder.decode(SaveState.self, from: jsonData)
        
            // Double escape JSON input to pass as a parameter inside evaluateScriptInContext
            var json = state.jsonState
            json = json.replacingOccurrences(of: "\\", with: "\\\\")
            json = json.replacingOccurrences(of: "\"", with: "\\\"")
            json = json.replacingOccurrences(of: "\'", with: "\\\'")
            //json = json.replacingOccurrences(of: "\n", with: "\\n")
            json = json.replacingOccurrences(of: "\n", with: "\\n")
            json = json.replacingOccurrences(of: "\r", with: "\\r")
            //json = json.replacingOccurrences(of: "\f", with: "\\f")
            
            jsContext.evaluateScript("story.state.LoadJson(\"\(json)\");")
            currentTags = state.currentTags
            print("Succesfully restored state from JSON string.")
            continueStory()
        } catch {
            print("Error while loading: ", error)
        }
        
        //print(jsContext.evaluateScript("story.hasError;")?.toBool() ?? false)
        //print(jsContext.evaluateScript("story.currentErrors;")?.toArray() ?? [])
        
    }
    
    func moveToKnitStitch(_ knot: String, stitch: String? = nil) {
        var path = knot
        if let s = stitch {
            path += ".\(s)"
        }
                
        print("moveToKnitStitch: path: \(path)")
        
        jsContext.evaluateScript("story.ChoosePathString(\"\(path)\")")
        continueStory()
    }
    
    func getVariable(_ variable: String) -> JSValue {
        return jsContext.evaluateScript("story.variablesState[\"\(variable)\"];")
    }
    
    func setVariable(_ variable: String, to value: String) {
        jsContext.evaluateScript("story.variablesState[\"\(variable)\"] = \(value);")
    }
    
    func setVariable(_ variable: String, to value: Int) {
        jsContext.evaluateScript("story.variablesState[\"\(variable)\"] = \(value);")
    }
    
    func setVariable(_ variable: String, to value: Double) {
        jsContext.evaluateScript("story.variablesState[\"\(variable)\"] = \(value);")
    }
    
    func registerObservedVariable(_ variableName: String) {
        if oberservedVariables.keys.contains(variableName) == false {
            oberservedVariables[variableName] = JSValue(nullIn: jsContext)
        }
    }
    
    func deregisterObservedVariable(_ variableName: String) {
        if oberservedVariables.keys.contains(variableName) {
            oberservedVariables.removeValue(forKey: variableName)
        }
    }
    
    private func refreshObservedVariables() {
        for key in oberservedVariables.keys {
            oberservedVariables[key] = getVariable(key)
        }
    }
}

struct Option {
    let index: Int
    let text: String
}
