import Foundation

public protocol UsersProviderType {
	func getUsers()
	func getUser(with id: Int)
}

public struct UsersProvider: UsersProviderType {
	public func getUsers() {
		//Implement the functionality
        
	}
	public func getUser(with id: Int) {
		//Implement the functionality
	}
}
