import Foundation

struct TrustedContact: Identifiable, Codable {
    var id: UUID
    var name: String
    var contactMethod: String

    init(id: UUID = UUID(), name: String, contactMethod: String) {
        self.id = id
        self.name = name
        self.contactMethod = contactMethod
    }
}
