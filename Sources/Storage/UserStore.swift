import Foundation

class UserStore {
    public static func store(user: APIClient.User) {
        UserDefaults.standard.set(user.username, forKey: UserDefaultsKeys.username)
        UserDefaults.standard.set(user.displayName, forKey: UserDefaultsKeys.userDisplay)
        UserDefaults.standard.set(user.id, forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.set(user.email, forKey: "email")
        UserDefaults.standard.set(user.image, forKey: UserDefaultsKeys.userImage)
    }

    public static func get() -> APIClient.User {
        return APIClient.User(
            id: UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId),
            displayName: UserDefaults.standard.string(forKey: UserDefaultsKeys.userDisplay) ?? "",
            username: UserDefaults.standard.string(forKey: UserDefaultsKeys.username) ?? "",
            email: UserDefaults.standard.string(forKey: "email") ?? "",
            image: UserDefaults.standard.string(forKey: UserDefaultsKeys.userImage) ?? ""
        )
    }
}
