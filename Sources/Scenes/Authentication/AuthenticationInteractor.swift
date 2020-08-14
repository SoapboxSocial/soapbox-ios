//
//  AuthenticationInteractor.swift
//  Voicely
//
//  Created by Dean Eigenmann on 12.08.20.
//

import Foundation
import KeychainAccess
import UIWindowTransitions

protocol AuthenticationInteractorOutput {
    func present(error: AuthenticationInteractor.AuthenticationError)
    func present(state: AuthenticationInteractor.AuthenticationState)
    func presentLoggedInView()
}

class AuthenticationInteractor: AuthenticationViewControllerOutput {
    private let output: AuthenticationInteractorOutput
    private let api: APIClient

    private var token: String?

    enum AuthenticationState: Int {
        case login, pin, registration, requestNotifications, success
    }

    enum AuthenticationError {
        case invalidEmail, invalidPin, invalidUsername, usernameTaken, general
    }

    init(output: AuthenticationInteractorOutput, api: APIClient) {
        self.output = output
        self.api = api
    }

    func login(email: String?) {
        guard let input = email, isValidEmail(input) else {
            return output.present(error: .invalidEmail)
        }

        api.login(email: input) { result in
            switch result {
            case .failure:
                self.output.present(error: .general)
            case let .success(token):
                self.token = token
                self.output.present(state: .pin)
            }
        }
    }

    func submitPin(pin: String?) {
        guard let input = pin else {
            return output.present(error: .invalidPin)
        }

        api.submitPin(token: token!, pin: input) { result in
            switch result {
            case let .failure(error):
                if error == .incorrectPin {
                    return self.output.present(error: .invalidPin)
                }

                return self.output.present(error: .general)
            case let .success(response):
                switch response.0 {
                case .success:
                    guard let user = response.1, let expires = response.2 else {
                        return self.output.present(error: .general)
                    }

                    self.store(token: self.token!, expires: expires, user: user)

                    DispatchQueue.main.async {
                        self.output.presentLoggedInView()
                    }
                case .register:
                    self.output.present(state: .registration)
                }
            }
        }
    }

    func register(username: String?, displayName: String?) {
        guard let usernameInput = username, isValidUsername(usernameInput) else {
            return output.present(error: .invalidUsername)
        }

        api.register(token: token!, username: usernameInput, displayName: displayName ?? usernameInput) { result in
            switch result {
            case let .failure(error):
                if error == .usernameAlreadyExists {
                    return self.output.present(error: .usernameTaken)
                }

                return self.output.present(error: .general)
            case let .success((user, expires)):
                self.store(token: self.token!, expires: expires, user: user)
                DispatchQueue.main.async {
                    self.output.present(state: .requestNotifications)

                    NotificationManager.shared.delegate = self
                    NotificationManager.shared.requestAuthorization()
                }
            }
        }
    }

    private func isValidUsername(_ username: String) -> Bool {
        if username.count >= 100 || username.count < 3 {
            return false
        }

        let usernameRegexEx = "^([A-Za-z0-9_]+)*$"

        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegexEx)
        return usernamePred.evaluate(with: username)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func store(token: String, expires: Int, user: APIClient.User) {
        let keychain = Keychain(service: "com.voicely.voicely")
        try? keychain.set(token, key: "token")
        try? keychain.set(String(Int(Date().timeIntervalSince1970) + expires), key: "expiry")

        UserStore.store(user: user)
    }
}

extension AuthenticationInteractor: NotificationManagerDelegate {
    func deviceTokenFailedToSet() {
        output.present(state: .success)
    }

    func deviceTokenWasSet() {
        self.output.present(state: .success)
    }
}
