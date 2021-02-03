import Foundation

// @todo what we want to do is store the user
class UserStore {
    public static func store(user: APIClient.User) {
        UserDefaults.standard.set(user.username, forKey: UserDefaultsKeys.username)
        UserDefaults.standard.set(user.displayName, forKey: UserDefaultsKeys.userDisplay)
        UserDefaults.standard.set(user.id, forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.set(user.email, forKey: "email")
        UserDefaults.standard.set(user.image, forKey: UserDefaultsKeys.userImage)
    }
}
