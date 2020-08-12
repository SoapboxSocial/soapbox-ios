//
//  AuthenticationPresenter.swift
//  Voicely
//
//  Created by Dean Eigenmann on 12.08.20.
//

import Foundation

enum ErrorStyle {
    case normal, floating
}

protocol AuthenticationPresenterOutput {
    func displayError(_ style: ErrorStyle, title: String, description: String?)
}

class AuthenticationPresenter {}
