//
//  ProfileView.swift
//  Soapbox
//
//  Created by Jeffrey Reiner on 5/28/21.
//

import SwiftUI

enum IconButtonStyle {
    case primary, secondary
}

struct IconButton: View {
    var icon: String;
    var type: IconButtonStyle = .primary
    var action: () -> Void;
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 16, weight: .semibold))
            .frame(width: 40, height: 40)
            .foregroundColor(type == .primary ? .white : .primary)
            .background(type == .primary ? Color(.systemPurple) : Color(.systemGray5))
            .clipShape(Circle())
    }
}

struct PillButton: View {
    var text: String;
    var action: () -> Void;
    
    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(height: 40)
            .padding(.horizontal, 20)
            .background(Color(.systemPurple))
            .clipShape(Capsule())
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
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                ProfilePicture()
                
                Text(display_name).font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Text(bio)
            }
            
            HStack(spacing: 10) {
                Text(following).bold() + Text(" ") + Text("following_count").foregroundColor(.secondary)
                
                Text(followers_count).bold() + Text(" ") + Text("Followers").foregroundColor(.secondary)
            }
            
            HStack(spacing: 10) {
                if isFollowing {
                    PillButton(text: "Following", action: toggleFollowing)
                } else {
                    PillButton(text: "Follow", action: toggleFollowing)
                }
                
                if isNotifying {
                    IconButton(icon: "bell.fill", action: toggleNotifying)
                } else {
                    IconButton(icon: "bell", type: .secondary, action: toggleNotifying)
                }
                
                IconButton(icon: "link", type: .secondary, action: {})
                
                IconButton(icon: "link", type: .secondary, action: {})
            }
            
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().preferredColorScheme(.light)
    }
}
