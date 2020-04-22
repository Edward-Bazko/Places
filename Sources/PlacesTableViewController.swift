import UIKit

final class PlacesTableViewController: UITableViewController {
    private let store: PlaceStoring
    private var observer: Token?
    
    var didSelect: (Place) -> () = { _ in }
    
    init(store: PlaceStoring) {
        self.store = store
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My places"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: .cellIdentifier)
        observer = NotificationCenter.default.addObserver(descriptor: PlacesStore.didChangeNotification, using: handlePlacesChanged)
    }
    
    private func handlePlacesChanged(_ payload: PlacesStoreChangePayload) {
        switch payload.change {
        case .add(let index):
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .left)
        case .remove(let index):
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
        case .update(let index, let place):
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                configure(cell: cell, place: place)
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.places.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: .cellIdentifier, for: indexPath)
        let place = store.places[indexPath.row]
        configure(cell: cell, place: place)
        return cell
    }
    
    func configure(cell: UITableViewCell, place: Place) {
        cell.textLabel!.text = place.state.description
        cell.imageView!.image = store.thumbnailImageAssigned(to: place)
        cell.setNeedsLayout()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        store.remove(store.places[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(store.places[indexPath.row])
    }
}

fileprivate extension String {
    static let cellIdentifier = "Cell"
}
