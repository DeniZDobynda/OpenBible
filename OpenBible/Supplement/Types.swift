import Foundation

enum BonjourServerState {
    case greeting
    case teaching
    case waiting
    case inSync
    
}

enum BonjourClientGreetingOption: String {
    case firstMeet = "hi, ready to get to know me?"
    case confirm = "yes"
    case ready = "ready to receive"
    case done = "ok, next"
    case finished = "are you ok?"
    case bye = "bye"
    case regexForSync = "Sync\\((.+)\\):(\\d+)"
    //    case
}

enum SyncingModule {
    case module
    case books
    case chapters
}

enum SyncingState {
    case none
    case strongs(String)
    case module(SyncingModule)
    case spirit
}

struct SyncStrong {
    var number: Int
    var meaning: String?
    var original: String?
}
