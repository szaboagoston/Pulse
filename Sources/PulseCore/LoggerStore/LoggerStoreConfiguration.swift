// The MIT License (MIT)
//
// Copyright (c) 2020–2022 Alexander Grebenyuk (github.com/kean).

import Foundation
import CoreData
import Combine

extension LoggerStore {

    /// The store creation options.
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Creates store if the file is missing. The intermediate directories must
        /// already exist.
        public static let create = Options(rawValue: 1 << 0)

        /// Reduces store size when it reaches the size limit by by removing the least
        /// recently added messages and blobs.
        public static let sweep = Options(rawValue: 1 << 1)

        /// Flushes entities to disk immediately and synchronously.
        ///
        /// - warning: When this option is enabled, all writes to the store
        /// happen immediately and synchronously.
        ///
        /// - note: This option can be used to ensure that if the app crashes,
        /// as much logs as possible are saved persistently. It can also be
        /// used to increase remote logging speed.
        public static let synchronous = Options(rawValue: 1 << 2)
    }

    /// The store configuration.
    public struct Configuration: @unchecked Sendable {
        /// Size limit in bytes. `128 Mb` by default. The limit is approximate.
        ///
        /// - important: This limit also applies to small network responses stored inline.
        public var databaseSizeLimit: Int

        /// Size limit in bytes. `256 Mb` by default.
        public var blobsSizeLimit: Int

        var trimRatio = 0.7

        /// Every 20 minutes.
        var sweepInterval: TimeInterval = 1200

        /// Determines how often the messages are saved to the database. By default,
        /// 100 milliseconds - quickly enough, but avoiding too many individual writes.
        public var saveInterval: DispatchTimeInterval = .milliseconds(100)

        /// If `true`, the images added to the store as saved as small thumbnails.
        public var isStoringOnlyImageThumbnails = true

        /// Limit the maximum response size stored by the logger. The default
        /// value is `10 Mb`. The same limit applies to requests.
        public var responseBodySizeLimit: Int = 10 * 1048576

        /// By default, two weeks. The messages and requests that are older that
        /// two weeks will get automatically deleted.
        ///
        /// - note: This option request the store to be instantiated with a
        /// ``LoggerStore/Options/sweep`` option. The default store supports sweeps.
        public var maxAge: TimeInterval = 14 * 86400

        /// For tesing purposes.
        var makeCurrentDate: () -> Date = { Date() }

        /// Gets called when the store receives an event. You can use it to
        /// modify the event before it is stored in order, for example, filter
        /// out some sensitive information. If you return `nil`, the event
        /// is ignored completely.
        public var willHandleEvent: @Sendable (Event) -> Event? = { $0 }

        /// Initializes the configuration.
        ///
        /// - parameters:
        ///   - databaseSizeLimit: The approximate limit of the database size. `128 Mb`
        ///   - blobsSizeLimit: The approximate limit of the blob storage that
        ///   contains network responses (HTTP body). `256 Mb` by default.
        public init(databaseSizeLimit: Int = 128 * 1048576, blobsSizeLimit: Int = 256 * 1048576) {
            self.databaseSizeLimit = databaseSizeLimit
            self.blobsSizeLimit = blobsSizeLimit
        }
    }
}