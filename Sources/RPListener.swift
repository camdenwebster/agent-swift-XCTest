//
//  Listener.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Windmill Smart Solutions on 5/12/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import XCTest

public class RPListener: NSObject, XCTestObservation {
  
  private var reportingService: ReportingService?
  private let queue = DispatchQueue(label: "com.report_portal.reporting", qos: .utility)
  
  public override init() {
    super.init()
    
    
    XCTestObservationCenter.shared.addTestObserver(self)
  }
  
    private func readConfiguration(from testBundle: Bundle) -> AgentConfiguration {
        let infoPlistPath: String?
        
        #if os(macOS)
        if let bundlePath = testBundle.bundlePath as NSString? {
            infoPlistPath = bundlePath.appendingPathComponent("Contents/Info.plist")
        } else {
            infoPlistPath = nil
        }
        #else
        infoPlistPath = testBundle.path(forResource: "Info", ofType: "plist")
        #endif

        guard
        let bundlePath = infoPlistPath else {
              fatalError("Info.plist not found")
        }
        guard
        let bundleProperties = NSDictionary(contentsOfFile: bundlePath) as? [String: Any] else {
          fatalError("Could not read contents of Info.plist")
        }
        guard
        let shouldReport = bundleProperties["PushTestDataToReportPortal"] as? Bool else {
          fatalError("Missing key: PushTestDataToReportPortal")
        }
        guard
        let portalPath = bundleProperties["ReportPortalURL"] as? String else {
          fatalError("Missing key: ReportPortalURL")
        }
        guard
        let portalURL = URL(string: portalPath) else {
          fatalError("Invalid URL string: \(portalPath)")
        }
        guard
        let projectName = bundleProperties["ReportPortalProjectName"] as? String else {
          fatalError("Missing key: ReportPortalProjectName")
        }
        guard
        let token = bundleProperties["ReportPortalToken"] as? String else {
          fatalError("Missing key: ReportPortalToken")
        }
        guard
        let shouldFinishLaunch = bundleProperties["IsFinalTestBundle"] as? Bool else {
          fatalError("Missing key: IsFinalTestBundle")
        }
        guard
        let launchName = bundleProperties["ReportPortalLaunchName"] as? String else {
          fatalError("Missing key: ReportPortalLaunchName")
        }
        var tags: [String] = []
        if let tagString = bundleProperties["ReportPortalTags"] as? String {
          tags = tagString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: ",")
        }
        var launchMode: LaunchMode = .default
        if let isDebug = bundleProperties["IsDebugLaunchMode"] as? Bool, isDebug == true {
          launchMode = .debug
        }

        var testNameRules: NameRules = []
        if let rules = bundleProperties["TestNameRules"] as? [String: Bool] {
          if rules["StripTestPrefix"] == true {
            testNameRules.update(with: .stripTestPrefix)
          }
          if rules["WhiteSpaceOnUnderscore"] == true {
            testNameRules.update(with: .whiteSpaceOnUnderscore)
          }
          if rules["WhiteSpaceOnCamelCase"] == true {
            testNameRules.update(with: .whiteSpaceOnCamelCase)
          }
        }

        return AgentConfiguration(
          reportPortalURL: portalURL,
          projectName: projectName,
          launchName: launchName,
          shouldSendReport: shouldReport,
          portalToken: token,
          tags: tags,
          shouldFinishLaunch: shouldFinishLaunch,
          launchMode: launchMode,
          testNameRules: testNameRules
        )
      }
  
  public func testBundleWillStart(_ testBundle: Bundle) {
    let configuration = readConfiguration(from: testBundle)
    
    guard configuration.shouldSendReport else {
      print("Set 'YES' for 'PushTestDataToReportPortal' property in Info.plist if you want to put data to report portal")
      return
    }
    let reportingService = ReportingService(configuration: configuration)
    self.reportingService = reportingService
    queue.async {
      do {
        try reportingService.startLaunch()
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testSuiteWillStart(_ testSuite: XCTestSuite) {
    guard let reportingService = self.reportingService else { return }
    
    guard
      !testSuite.name.contains("All tests"),
      !testSuite.name.contains("Selected tests") else
    {
      return
    }
    
    queue.async {
      do {
        if testSuite.name.contains(".xctest") {
          try reportingService.startRootSuite(testSuite)
        } else {
          try reportingService.startTestSuite(testSuite)
        }
      } catch let error {
        print(error)
      }
    }
  }

  public func testCaseWillStart(_ testCase: XCTestCase) {
    guard let reportingService = self.reportingService else { return }

    queue.async {
      do {
        try reportingService.startTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }

  public func testCase(_ testCase: XCTestCase, didRecord issue: XCTIssueReference) {
    guard let reportingService = self.reportingService else { return }

    queue.async {
      do {
        let lineNumberString = issue.sourceCodeContext.location?.lineNumber != nil
          ? " on line \(issue.sourceCodeContext.location!.lineNumber)"
          : ""
        let errorMessage = "Test '\(String(describing: issue.description))' failed\(lineNumberString), \(issue.description)"

        try reportingService.reportError(message: errorMessage)
      } catch let error {
        print(error)
      }
    }
  }

  public func testCaseDidFinish(_ testCase: XCTestCase) {
    guard let reportingService = self.reportingService else { return }

    
    queue.async {
      do {
        try reportingService.finishTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    guard let reportingService = self.reportingService else { return }

    
    guard
      !testSuite.name.contains("All tests"),
      !testSuite.name.contains("Selected tests") else
    {
      return
    }
    
    queue.async {
      do {
        if testSuite.name.contains(".xctest") {
          try reportingService.finishRootSuite()
        } else {
          try reportingService.finishTestSuite()
        }
      } catch let error {
        print(error)
      }
    }
  }
  
  public func testBundleDidFinish(_ testBundle: Bundle) {
    guard let reportingService = self.reportingService else { return }

    queue.sync() {
      do {
        try reportingService.finishLaunch()
      } catch let error {
        print(error)
      }
    }
  }
}
