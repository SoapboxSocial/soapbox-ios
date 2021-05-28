//
//  ProfileView.swift
//  Soapbox
//
//  Created by Jeffrey Reiner on 5/28/21.
//

import SwiftUI

struct ProfileView: View {
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
                Image(systemName: "")
                    .frame(width: 80, height: 80)
                    .background(Color(.systemPurple))
                    .clipShape(Circle())
                
                Text("Amy").font(.system(size: 24)).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Text("About Me. Think you can beat my Flappy Bird score? Try me.")
            }
            
            HStack(spacing: 10) {
                Text("2,400").bold() + Text(" ") + Text("Following").foregroundColor(.secondary)
                
                Text("1,100").bold() + Text(" ") + Text("Followers").foregroundColor(.secondary)
            }
            
            HStack(spacing: 10) {
                if isFollowing {
                    Text("Following")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .padding(.horizontal, 20)
                        .background(Color(.systemPurple))
                        .clipShape(Capsule())
                } else {
                    Text("Follow")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .padding(.horizontal, 20)
                        .background(Color(.systemPurple))
                        .clipShape(Capsule())
                }
                
                if isNotifying {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .foregroundColor(.primary)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }
                
                Image(systemName: "link")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.primary)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                
                Image(systemName: "link")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .foregroundColor(.primary)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
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
