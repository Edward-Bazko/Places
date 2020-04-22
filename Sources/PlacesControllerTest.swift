import XCTest

class PlacesControllerTest: XCTestCase {
    var sut: PlacesController!
    
    override func setUp() {
        super.setUp()
        sut = PlacesController()
    }
    
    func testExample() {
        XCTAssertNotNil(sut)
    }    
}
