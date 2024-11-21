import SwiftyUserDefaults

//public let Defaults = UserDefaults.standard

public extension DefaultsKeys {
    var lastMigratedVersion: DefaultsKey<String?> { .init("yippi.app.lastMigratedVersion") }
    var apiToken: DefaultsKey<String?> { .init("yippi.app.apiToken") }
    var serverConfig: DefaultsKey<ServerConfig?> { .init("yippi.app.serverConfig") }
    var currentUser: DefaultsKey<TSUser?> { .init("yippi.app.currentUser") }
    var appInfo: DefaultsKey<AppInfo?> { .init("yippi.app.appInfo") }
    var featureFlags: DefaultsKey<FeatureFlags?> { .init("yippi.app.featureFlags") }
    var globalChatWallpaperImage: DefaultsKey<Data?> { .init(Constants.GlobalChatWallpaperImageKey) }
    var currentLanguage: DefaultsKey<String?> { .init("yippi.app.currentLanguage") }
}
