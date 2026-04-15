import Testing
import Foundation
@testable import ReportPortalAgent

// MARK: - Stub conformers for protocol tests

private final class DefaultAttributesStub: NSObject, RPAttributable {}

private final class CustomAttributesStub: NSObject, RPAttributable {
    var rpAttributes: [String: String]? {
        ["component": "login", "scenario_owner": "alice"]
    }
}

// MARK: - Tests

@Suite("Custom Attributes")
struct CustomAttributesTests {

    // MARK: - Group A: RPAttributable protocol

    @Test func rpAttributable_defaultImplReturnsNil() {
        #expect(DefaultAttributesStub().rpAttributes == nil)
    }

    @Test func rpAttributable_customImplReturnsExpectedDict() {
        #expect(CustomAttributesStub().rpAttributes == ["component": "login", "scenario_owner": "alice"])
    }

    // MARK: - Group B: StartItemEndPoint carries attributes

    @Test func startItemEndPoint_attributesAppearedInParameters() {
        let attrs: [[String: String]] = [["key": "component", "value": "checkout"]]
        let endPoint = StartItemEndPoint(
            itemName: "MyTests",
            launchID: "launch-abc",
            type: .test,
            attributes: attrs
        )
        let params = endPoint.parameters["attributes"] as? [[String: String]]
        #expect(params?.contains(["key": "component", "value": "checkout"]) == true)
    }

    // MARK: - Group C: AgentConfiguration launchAttributes

    @Test func agentConfiguration_holdsLaunchAttributes() {
        let attrs: [[String: String]] = [["key": "env", "value": "prod"]]
        let config = AgentConfiguration(
            reportPortalURL: URL(string: "https://example.com")!,
            projectName: "proj",
            launchName: "launch",
            shouldSendReport: true,
            portalToken: "token",
            tags: [],
            launchAttributes: attrs,
            launchMode: .default,
            testNameRules: []
        )
        #expect(config.launchAttributes == attrs)
    }

    // MARK: - Attribute dict → API format conversion

    @Test func attributeMapping_convertsToAPIFormat() {
        let dict: [String: String] = ["component": "checkout"]
        let mapped = dict.map { ["key": $0.key, "value": $0.value] }
        #expect(mapped.count == 1)
        #expect(mapped.contains(["key": "component", "value": "checkout"]))
    }
}
