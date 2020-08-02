//
//  RoomMemberCell.swift
//  Voicely
//
//  Created by Dean Eigenmann on 29.07.20.
//

import UIKit

class RoomMemberCell: UICollectionViewCell {
    
    private var isSelfLabel: UILabel!
    private var roleLabel: UILabel!
    private var muteView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let circle = UIView(frame: contentView.frame)
        circle.layer.cornerRadius = 30
        circle.clipsToBounds = true
        circle.backgroundColor = .highlight
        
        isSelfLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        isSelfLabel.text = "You"
        isSelfLabel.textAlignment = .center
        isSelfLabel.textColor = .elementBackground
        circle.addSubview(isSelfLabel)
        
        contentView.addSubview(circle)
        
        let roleView = UIView(frame: CGRect(x: 60 - 20, y: 0, width: 20, height: 20))
        roleView.backgroundColor = .background
        roleView.layer.cornerRadius = 10
        roleView.clipsToBounds = true
        contentView.addSubview(roleView)

        roleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        roleLabel.textAlignment = .center
        roleLabel.font = roleLabel.font.withSize(10)
        roleView.addSubview(roleLabel)
        
        muteView = UIView(frame: CGRect(x: 60 - 20, y: 60 - 20, width: 20, height: 20))
        muteView.backgroundColor = .background
        muteView.layer.cornerRadius = 10
        muteView.clipsToBounds = true
        muteView.isHidden = true
        contentView.addSubview(muteView)

        let muteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        muteLabel.text = "🔇"
        muteLabel.textAlignment = .center
        muteLabel.font = muteLabel.font.withSize(10)
        muteView.addSubview(muteLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(isSelf: Bool, role: APIClient.MemberRole) {
        if isSelf {
            isSelfLabel.isHidden = false
        } else {
            isSelfLabel.isHidden = true
        }
        
        roleLabel.text = emoji(for: role)
    }

    func setup(isSelf: Bool, member: APIClient.Member) {
        setup(isSelf: isSelf, role: member.role)
        
        if member.isMuted {
            muteView.isHidden = false
        } else {
            muteView.isHidden = true
        }

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
