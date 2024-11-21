import Foundation

public protocol ServicesType {
	var usersProvider: UsersProviderType! { get }
}

public struct Services: ServicesType {
	public var usersProvider: UsersProviderType!
	
	public init() {
		self.usersProvider = UsersProvider()
	}
}
