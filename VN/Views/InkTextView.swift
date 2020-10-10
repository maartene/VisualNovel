//
//  InkTextView.swift
//  VN
//
//  Created by Maarten Engels on 09/10/2020.
//

import SwiftUI

struct InkTextView: View {
    @ObservedObject var story: InkStory
    
    var text: (text: String, name: String?) {
        let string = story.currentText
                        
        if string.contains(":") {
            let split = string.split(separator: ":")
            return (String(split[1]), String(split[0].trimmingCharacters(in: .punctuationCharacters)))
        } else {
            return (string, nil)
        }
    }
    
    var body: some View {
        VStack {
            // Display the current line of text from the story.
            if let name = text.name {
                Text(name).font(.custom("American Typewriter", size: 48)).bold().padding()
            }
            Text(text.text).font(.custom("American Typewriter", size: 48)).padding()
            
            HStack {
                // Display the "Continue" button if the story can (i.e. is waiting for) continue.
                if story.canContinue {
                    Button(action: {
                        story.continueStory()
                    } , label: {
                        Text("Continue").padding()
                    }).buttonStyle(CardButtonStyle()).padding(.horizontal)
                }
                
                // If any options are available, show them as buttons.
                ForEach(story.options, id: \.index) { option in
                    Button(action: {
                        story.chooseChoiceIndex(option.index)
                    }, label: {
                        Text(option.text).padding()
                    }).buttonStyle(CardButtonStyle()).padding(.horizontal)
                }
                
            }.font(.custom("American Typewriter", size: 32)).padding(.bottom).padding(.bottom)
        }
    }
}

struct InkTextView_Previews: PreviewProvider {
    static var previews: some View {
        InkTextView(story: InkStory())
    }
}
