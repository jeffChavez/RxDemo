import Foundation

struct Document {
    let header: Header
    let body: Body
    let footer: Footer
}

struct Header {
    let text: String
}

struct Body {
    let text: String
}

struct Footer {
    let text: String
}

struct HeaderViewState {
    let labelText: String

    static func loading() -> HeaderViewState {
        return HeaderViewState(labelText: "Loading...")
    }
}

struct BodyViewState {
    let labelText: String

    static func loading() -> BodyViewState {
        return BodyViewState(labelText: "Loading...")
    }
}

struct FooterViewState {
    let labelText: String

    static func loading() -> FooterViewState {
        return FooterViewState(labelText: "Loading...")
    }
}
