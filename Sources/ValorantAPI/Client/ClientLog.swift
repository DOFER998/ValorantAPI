import Foundation
import Protoquest
import Collections

public struct ClientLog {
	public let maxCount: Int
	public private(set) var exchanges: Deque<Exchange> = []
	
	public init(maxCount: Int = 50) {
		self.maxCount = maxCount
	}
	
	public mutating func logExchange(request: URLRequest, result: Protoresult) {
		if exchanges.count >= maxCount {
			exchanges.removeFirst()
		}
		exchanges.append(.init(request: request, result: result))
	}
	
	public struct Exchange: Identifiable {
		public var id = ObjectID<Self, UUID>(rawID: .init())
		public var time = Date.now
		public var request: URLRequest
		public var result: Protoresult
		
		public var statusCode: Int? {
			try? result.get().httpMetadata?.statusCode
		}
	}
}
