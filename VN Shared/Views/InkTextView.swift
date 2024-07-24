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
            .font(.buttonText)
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue.opacity(0.6))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
            if let name = text.name {
                Text(name)
                    .font(.storyTextLarge.bold())
                    .padding()
            }
            Text(text.text)
                .font(.storyText)
                .padding()
            
            HStack {
                if story.canContinue {
                    Button(action: {
                        story.continueStory()
                    }) {
                        Text("Continue")
                            .padding()
                    }
                    .buttonStyle(VNButtonStyle())
                    .padding(.horizontal)
                }
                
                ForEach(story.options, id: \.index) { option in
                    Button(action: {
                        story.chooseChoiceIndex(option.index)
                    }) {
                        Text(option.text)
                            .padding()
                    }
                    .buttonStyle(VNButtonStyle())
                    .padding(.horizontal)
                }
            }
            .font(.buttonText)
            .padding(.bottom)
        }
    }
}

struct InkTextView_Previews: PreviewProvider {
    static var previews: some View {
        InkTextView(story: InkStory())
    }
}
