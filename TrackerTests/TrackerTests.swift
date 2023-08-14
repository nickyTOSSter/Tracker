//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Никита Чагочкин on 12.08.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {


    func testViewController() throws {
        let vc = (UIApplication.shared.delegate as! AppDelegate).trackersTabBarController
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
    }

    func testViewControllerDark() throws {
        let vc = (UIApplication.shared.delegate as! AppDelegate).trackersTabBarController
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }


}
