//
//  RoomMemberCell.swift
//  Voicely
//
//  Created by Dean Eigenmann on 29.07.20.
//

import UIKit

class RoomMemberCell: UICollectionViewCell {
  
    func setup(isSelf: Bool, role: APIClient.MemberRole) {
        
        let circle = UIView(frame: contentView.frame)
        circle.layer.cornerRadius = 30
        circle.clipsToBounds = true
        circle.backgroundColor = .highlight
        
        if isSelf {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            label.text = "You"
            label.textAlignment = .center
            label.textColor = .elementBackground
            circle.addSubview(label)
        }
        
        contentView.addSubview(circle)
        
        let roleView = UIView(frame: CGRect(x: 60 - 20, y: 0, width: 20, height: 20))
        roleView.backgroundColor = .background
        roleView.layer.cornerRadius = 10
        roleView.clipsToBounds = true
        contentView.addSubview(roleView)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.text = emoji(for: role)
        label.textAlignment = .center
        label.font = label.font.withSize(10)
        roleView.addSubview(label)
        
    }
    
    private func emoji(for role: APIClient.MemberRole) -> String {
        switch role {
        case .audience:
            return "👂"
        case .owner:
            return "👑"
        case .speaker:
            return "🎙️"
        }
    }
}
