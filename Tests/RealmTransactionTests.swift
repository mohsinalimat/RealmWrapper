import XCTest

import RealmSwift

class RealmTransactionTests: XCTestCase {
    
    let userCount = 100000
    
    override func setUp() {
        super.setUp()
        
        UserRealmManager().clear()
    }
    
    func testDefaultTransaction() {
        UserRealmManager().transaction(writeHandler: { (realm) in
            self.addUser(count: self.userCount, realm: realm)
            
            let users = realm.objects(User.self)
            XCTAssertEqual(users.count, self.userCount)
        })
    }
    
    func testDefaultAsyncTransaction() {
        let expectation = self.expectation(description: "testCreateNotification")
        
        UserRealmManager().transaction(isSync: false, writeHandler: { (realm) in
            self.addUser(count: self.userCount, realm: realm)
        }) { (realm, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(realm)
            
            let users = realm!.objects(User.self)
            XCTAssertEqual(users.count, self.userCount)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60)
    }
    
    func testCustomSyncTransaction() {
        UserRealmManager().transaction(writeQueue: DispatchQueue(label: "testCustomSyncTransaction"), writeHandler: { (realm) in
            self.addUser(count: self.userCount, realm: realm)
            
            let users = realm.objects(User.self)
            XCTAssertEqual(users.count, self.userCount)
        })
    }
    
    func testCustomAsyncTransaction() {
        let expectation = self.expectation(description: "testCreateNotification")
        
        UserRealmManager().transaction(writeQueue: DispatchQueue(label: "testCustomAsyncTransaction"), isSync: false, writeHandler: { (realm) in
            self.addUser(count: self.userCount, realm: realm)
        }) { (realm, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(realm)
            
            let users = realm!.objects(User.self)
            XCTAssertEqual(users.count, self.userCount)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60)
    }
    
    // MARK: - Private methods
    
    private func addUser(count: Int, realm: Realm) {
        for i in 0..<count {
            let user = User(name: "user-\(i)", age: i)
            realm.add(user)
        }
    }
    
}
