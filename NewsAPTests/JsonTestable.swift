protocol DictionaryInitable {
    init?(_ dict: [String: Any])
}

typealias TestField<F> = (parseKey: String, actualField: F, expectedField: F)
protocol JsonTestable {
    func tstField<F, T>(_ field: TestField<F>,
                  type: T.Type,
                  validDict: [String: Any]) where F: Equatable, T: DictionaryInitable
}
import XCTest
extension JsonTestable {
    func tstField<F, T>(_ field: TestField<F>,
                  type: T.Type,
                  validDict: [String: Any]) where F: Equatable, T: DictionaryInitable {
        XCTAssertEqual(field.actualField, field.expectedField)
        tstWithInvalidFieldType(field, type: type, validDict: validDict)
        XCTAssertNil(T(invalidDict(field.parseKey, value: nil, validDict: validDict)))
    }
    private func tstWithInvalidFieldType<F, T>(_ field: TestField<F>,
                                         type: T.Type,
                                         validDict: [String: Any]) where T: DictionaryInitable {
        if field.actualField is String {
            XCTAssertNil(T(invalidDict(field.parseKey, value: 3, validDict: validDict)))
        }else{
            XCTAssertNil(T(invalidDict(field.parseKey, value: "test", validDict: validDict)))
        }
    }
    private func invalidDict(_ key: String, value: Any?,  validDict: [String: Any]) -> [String: Any] {
        var dict = validDict
        dict[key] = value
        return dict
    }
}
