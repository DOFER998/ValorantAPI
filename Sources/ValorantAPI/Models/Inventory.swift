import Foundation

public struct Inventory: Codable {
	public static let starterAgents: Set<Agent.ID> = [.jett, .phoenix, .sova, .brimstone, .sage]
	
	public let agents: Set<Agent.ID>
	public let agentsIncludingStarters: Set<Agent.ID>
	public let cards: Set<PlayerCard.ID>
	public let titles: Set<PlayerTitle.ID>
	public let skinLevels: Set<Weapon.Skin.Level.ID>
	public let skinChromas: Set<Weapon.Skin.Chroma.ID>
	public let sprays: Set<Spray.ID>
	public let contracts: Set<Contract.ID>
	public let buddies: [Weapon.Buddy.Level.ID: [Weapon.Buddy.Instance.ID]]
	
	init(_ raw: APIInventory) {
		let collections = Dictionary(
			uniqueKeysWithValues: raw.collectionsByType
				.map { ($0.id, $0) }
		)
		
		func collectItems<ID>(_ type: ItemCollection.ID) -> Set<ID>
		where ID: ObjectIDProtocol, ID.RawID == LowercaseUUID {
			Set(collections[type]?.items.lazy.map(\.id).map(ID.init(rawID:)) ?? [])
		}
		
		// TODO: use InventoryItem protocol to gather these instead?
		
		agents = collectItems(.agents)
		cards = collectItems(.cards)
		titles = collectItems(.titles)
		skinLevels = collectItems(.skinLevels)
		skinChromas = collectItems(.skinChromas)
		sprays = collectItems(.sprays)
		contracts = collectItems(.contracts)
		buddies = collections[.buddies]?.items.lazy.map(Buddy.init)
			.reduce(into: [:]) { $0[$1.level, default: []].append($1.instance) }
			?? [:]
		
		assert(agents.intersection(Self.starterAgents).isEmpty)
		agentsIncludingStarters = agents.union(Self.starterAgents)
	}
	
	public func owns<Item: InventoryItem, RawID: Hashable>(
		_ itemID: ObjectID<Item, RawID>
	) -> Bool where Item.ID == ObjectID<Item, RawID> { // don't think about it too hard…
		self[keyPath: Item.ownedItems].contains(itemID)
	}
	 
	private struct Buddy {
		var level: Weapon.Buddy.Level.ID
		var instance: Weapon.Buddy.Instance.ID
		
		init(_ item: Item) {
			level = .init(rawID: item.id)
			instance = .init(rawID: item.instanceID!)
		}
	}
}

public protocol InventoryItem {
	associatedtype OwnedItems: Collection<ID>
	associatedtype ID: Hashable
	
	static var ownedItems: KeyPath<Inventory, OwnedItems> { get }
}

extension Agent: InventoryItem {
	public static let ownedItems = \Inventory.agentsIncludingStarters
}

extension PlayerCard: InventoryItem {
	public static let ownedItems = \Inventory.cards
}

extension PlayerTitle: InventoryItem {
	public static let ownedItems = \Inventory.titles
}

extension Weapon.Skin.Level: InventoryItem {
	public static let ownedItems = \Inventory.skinLevels
}

extension Weapon.Skin.Chroma: InventoryItem {
	public static let ownedItems = \Inventory.skinChromas
}

extension Spray: InventoryItem {
	public static let ownedItems = \Inventory.sprays
}

extension Weapon.Buddy.Level: InventoryItem {
	public static let ownedItems = \Inventory.buddies.keys
}

private extension ItemCollection.ID {
	static let agents = Self("01bb38e1-da47-4e6a-9b3d-945fe4655707")!
	static let cards = Self("3f296c07-64c3-494c-923b-fe692a4fa1bd")!
	static let titles = Self("de7caa6b-adf7-4588-bbd1-143831e786c6")!
	static let skinLevels = Self("e7c63390-eda7-46e0-bb7a-a6abdacd2433")!
	static let skinChromas = Self("3ad1b2b2-acdb-4524-852f-954a76ddae0a")!
	static let sprays = Self("d5f120f8-ff8c-4aac-92ea-f2b5acbe9475")!
	static let contracts = Self("f85cb6f7-33e5-4dc8-b609-ec7212301948")!
	static let buddies = Self("dd3bf334-87f3-40bd-b043-682a57a8dc3a")!
}

struct APIInventory: Decodable {
	fileprivate var collectionsByType: [ItemCollection]
	
	private enum CodingKeys: String, CodingKey {
		case collectionsByType = "EntitlementsByTypes"
	}
}

private struct ItemCollection: Decodable {
	typealias ID = ObjectID<Self, LowercaseUUID>
	
	var id: ID
	var items: [Item]
	
	private enum CodingKeys: String, CodingKey {
		case id = "ItemTypeID"
		case items = "Entitlements"
	}
}

private struct Item: Decodable {
	var id: LowercaseUUID
	var instanceID: LowercaseUUID?
	
	private enum CodingKeys: String, CodingKey {
		case id = "ItemID"
		case instanceID = "InstanceID"
	}
}
