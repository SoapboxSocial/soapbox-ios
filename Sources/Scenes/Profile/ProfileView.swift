//
//  ProfileView.swift
//  Soapbox
//
//  Created by Jeffrey Reiner on 5/28/21.
//

import SwiftUI

struct PillButtonStyle: ButtonStyle {
    var bgColor: Color = Color(.brandColor)
    var fgColor: Color = .white
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(height: 40)
            .padding(.horizontal, 20)
            .background(bgColor)
            .clipShape(Capsule())
            .foregroundColor(fgColor)
            .font(.body.weight(.semibold))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.4)
                .delay(0)
            )
    }
}

struct IconButtonStyle: ButtonStyle {
    var bgColor: Color
    var fgColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(width: 40, height: 40)
            .background(bgColor)
            .foregroundColor(fgColor)
            .font(.body.weight(.semibold))
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.4)
                .delay(0)
            )
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style = .medium

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: style);
        
        indicator.color = UIColor.white
        
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

extension String {
   func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

struct PillButtonWithLoadingIndicator: View {
    var label: String
    var isLoading: Bool
    var action: () -> Void;
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if isLoading {
                    ActivityIndicator(isAnimating: .constant(isLoading))
                } else {
                    Text(label)
                }
            }.frame(width: label.widthOfString(usingFont: UIFont.systemFont(ofSize: 17, weight: .bold)))
        }.buttonStyle(PillButtonStyle())
    }
}

struct IconButton: View {
    var icon: Image;
    var type: Style = .primary
    var action: () -> Void;
    
    enum Style {
        case primary, secondary
    }
    
    var body: some View {
        Button(action: action) {
            icon
        }
            .buttonStyle(IconButtonStyle(
                bgColor: type == .primary ? Color(.brandColor) : Color(.systemGray5),
                fgColor: type == .primary ? .white : .primary)
            )
    }
}

struct ProfilePicture: View {
    var body: some View {
        Image(systemName: "")
            .frame(width: 80, height: 80)
            .background(Color(.brandColor))
            .clipShape(Circle())
    }
}

struct ProfileView: View {
    var display_name: String = "Amy"
    var bio: String = "About Me. Think you can beat my Flappy Bird score? Try me."
    var followers_count: String = "1,100"
    var following_count: String = "2,400"
    
    @State private var isFollowing = true
    @State private var isNotifying = true
    
    @State private var isLoading = false;
    
    func toggleFollowing() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isFollowing.toggle()
            
            isLoading = false
        }
    }
    
    func toggleNotifying() {
        isNotifying.toggle()
    }
    
    var body: some View {
        ScrollView() {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    ProfilePicture()
                    
                    Text(display_name).font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    
                    Text(bio)
                }
                
                HStack(spacing: 10) {
                    Text(following_count).bold() + Text(" ") + Text("Following").foregroundColor(.secondary)
                    
                    Text(followers_count).bold() + Text(" ") + Text("Followers").foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                HStack(spacing: 10) {
                    PillButtonWithLoadingIndicator(label: isFollowing ? "Following" : "Follow", isLoading: isLoading, action: toggleFollowing)
                    
                    IconButton(icon: isNotifying ? Image(systemName: "bell.fill") : Image(systemName: "bell"), type: isNotifying ? .primary : .secondary, action: toggleNotifying)
                    
                    IconButton(icon: Image("twitter-outline"), type: .secondary, action: {})
                                        
                    Spacer()
                }
            }.padding(20)
            
            Divider()
            
            VStack {
                HStack {
                    Text("Your Bubble").font(.system(size: 24)).bold()
                    
                    Spacer()
                }
            }.padding(20)
               
        }
        
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().preferredColorScheme(.dark)
    }
}
