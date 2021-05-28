//
//  ProfileView.swift
//  Soapbox
//
//  Created by Jeffrey Reiner on 5/28/21.
//

import SwiftUI

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(height: 40)
            .padding(.horizontal, 20)
            .background(Color(.systemPurple))
            .clipShape(Capsule())
            .foregroundColor(.white)
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
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.4)
                .delay(0)
            )
    }
}

struct IconButton: View {
    var icon: String;
    var type: Style = .primary
    var action: () -> Void;
    
    enum Style {
        case primary, secondary
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon).font(.body.weight(.semibold))
        }
            .buttonStyle(IconButtonStyle(
                bgColor: type == .primary ? Color(.systemPurple) : Color(.systemGray5),
                fgColor: type == .primary ? .white : .primary)
            )
    }
}

struct ProfilePicture: View {
    var body: some View {
        Image(systemName: "")
            .frame(width: 80, height: 80)
            .background(Color(.systemPurple))
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
    
    func toggleFollowing() {
        isFollowing.toggle()
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
                    if isFollowing {
                        Button("Following", action: toggleFollowing).buttonStyle(PillButtonStyle())
                    } else {
                        Button("Follow", action: toggleFollowing).buttonStyle(PillButtonStyle())
                    }
                    
                    IconButton(icon: isNotifying ? "bell.fill" : "bell", type: isNotifying ? .primary : .secondary, action: toggleNotifying)
                    
                    IconButton(icon: "link", type: .secondary, action: {})
                    
                    IconButton(icon: "link", type: .secondary, action: {})
                    
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
        ProfileView().preferredColorScheme(.light)
    }
}
