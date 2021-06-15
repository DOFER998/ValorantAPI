import Foundation

public struct LiveGameInfo: Codable {
	var id: Match.ID
	
	var players: [PlayerInfo]
	
	var state: State
	var mapID: MapID
	var modeID: GameModeID
	var provisioningFlowID: ProvisioningFlowID
	var matchmakingData: MatchmakingData
	var isReconnectable: Bool
	
	private enum CodingKeys: String, CodingKey {
		case id = "MatchID"
		
		case players = "Players"
		
		case state = "State"
		case mapID = "MapID"
		case modeID = "ModeID"
		case provisioningFlowID = "ProvisioningFlow"
		case matchmakingData = "MatchmakingData"
		case isReconnectable = "IsReconnectable"
	}
	
	struct State: SimpleRawWrapper {
		static let inProgress = Self("IN_PROGRESS")
		
		public var rawValue: String
		
		public init(_ rawValue: String) {
			self.rawValue = rawValue
		}
	}
	
	struct MatchmakingData: Codable {
		var queueID: QueueID
		var isRanked: Bool
		
		private enum CodingKeys: String, CodingKey {
			case queueID = "QueueID"
			case isRanked = "IsRanked"
		}
	}
	
	public struct PlayerInfo: Codable, Identifiable {
		public var id: Player.ID
		
		public var teamID: Team.ID
		public var agentID: Agent.ID
		public var identity: Player.Identity
		
		private enum CodingKeys: String, CodingKey {
			case id = "Subject"
			
			case teamID = "TeamID"
			case agentID = "CharacterID"
			case identity = "PlayerIdentity"
		}
	}
}