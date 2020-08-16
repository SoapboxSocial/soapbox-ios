//
//  Configuration.swift
//  Voicely
//
//  Created by Dean Eigenmann on 17.08.20.
//

import Foundation

class Configuration {
    private static let infoDictionary: [String: Any] = {
      guard let dict = Bundle.main.infoDictionary else {
        fatalError("Plist file not found")
      }

      return dict
    }()

    static let rootURL: URL = {
      guard let rootURLstring = Configuration.infoDictionary["ROOT_URL"] as? String else {
        fatalError("Root URL not set in plist for this environment")
      }
      guard let url = URL(string: rootURLstring) else {
        fatalError("Root URL is invalid")
      }

      return url
    }()

}
