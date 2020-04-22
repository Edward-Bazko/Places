import Foundation

extension NotificationCenter {
    func addObserver<A>(descriptor: NotificationDescriptor<A>, object: Any? = nil, queue: OperationQueue? = nil, using block: @escaping (A) -> ()) -> Token {
        let token = addObserver(forName: descriptor.name, object: nil, queue: queue, using: { note in
            block(note.object as! A)
        })
        return Token(token: token, center: self)
    }
    
    func post<A>(descriptor: NotificationDescriptor<A>, value: A) {
        post(name: descriptor.name, object: value)
    }
}

struct NotificationDescriptor<A> {
    let name: Notification.Name
}

class Token {
    let token: NSObjectProtocol
    let center: NotificationCenter
    
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}
