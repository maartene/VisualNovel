//
//  InkTextView.swift
//  VN
//
//  Created by Maarten Engels on 09/10/2020.
//

import SwiftUI


struct FormattedButton: ViewModifier {
    func body(content: Content) -> some View {
        
    #if os(tvOS)
        return content.buttonStyle(CardButtonStyle())
    #else
        return content.buttonStyle(VNButtonStyle())
    #endif
    }
}


struct VNButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.custom("American Typewriter", size: 42))
            .foregroundColor(Color.white)
            .padding()
            .background(Color.gray.opacity(0.5))
            .cornerRadius(15.0)
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
    }
}

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
                    }).modifier(FormattedButton()).padding(.horizontal)
                }
                
                // If any options are available, show them as buttons.
                ForEach(story.options, id: \.index) { option in
                    Button(action: {
                        story.chooseChoiceIndex(option.index)
                    }, label: {
                        Text(option.text).padding()
                    }).modifier(FormattedButton()).padding(.horizontal)
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
