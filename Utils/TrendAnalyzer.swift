//
//  TrendAnalyzer.swift
//  CheckIn
//
//  Created by CheckInApp on 2025-06-13.
//

import Foundation

/// A utility for evaluating behavioral and emotional trends over time.
/// Supports detection of downward trends, stagnation, and consistent lows across a 1–10 scale.
struct TrendAnalyzer {
    
    // MARK: - Core Threshold Settings
    private static let recentWindow = 7         // Number of days to evaluate
    private static let minimumWindow = 3        // Minimum required days for a valid trend
    
    // MARK: - Downward Trend Detection
    /// Returns true if recent values show a downward trend from baseline.
    /// Combines strict threshold logic and softer percentage-based decline detection.
    static func isDownwardTrend(
        _ values: [Int],
        baseline: Int,
        dropThreshold: Int = 2,
        percentDecline: Double = 0.2
    ) -> Bool {
        let recent = Array(values.suffix(recentWindow))
        guard recent.count >= minimumWindow else { return false }

        // Hard drop: all recent values below baseline - threshold
        let hardDrop = recent.suffix(minimumWindow).allSatisfy { $0 <= baseline - dropThreshold }

        // Soft drop: average of recent values drops ≥ percentDecline below baseline
        let average = Double(recent.reduce(0, +)) / Double(recent.count)
        let decline = Double(baseline) - average
        let percentDrop = decline / Double(baseline)
        let softDrop = percentDrop >= percentDecline

        return hardDrop || softDrop
    }
    
    // MARK: - Stagnation Detection
    /// Detects flat, below-baseline patterns (e.g., emotional stagnation or low interest)
    static func isFlatBelowBaseline(
        _ values: [Int],
        baseline: Int,
        flatRange: Int = 1,
        days: Int = 4
    ) -> Bool {
        let recent = Array(values.suffix(days))
        guard recent.count >= days else { return false }

        let flat = (recent.max() ?? 0) - (recent.min() ?? 0) <= flatRange
        let consistentlyLow = recent.allSatisfy { $0 <= baseline - 1 }

        return flat && consistentlyLow
    }

    // MARK: - Consistently Low Detection
    /// Flags if a metric has remained under a threshold for X consecutive days.
    static func isConsistentlyLow(
        _ values: [Int],
        threshold: Int = 4,
        days: Int = 3
    ) -> Bool {
        let recent = Array(values.suffix(days))
        guard recent.count >= days else { return false }
        return recent.allSatisfy { $0 <= threshold }
    }

    // MARK: - Recovery Trend Detection (Optional)
    /// Detects recovery patterns where a metric returns to or above baseline with upward movement.
    static func isImproving(
        _ values: [Int],
        baseline: Int,
        requiredUptick: Int = 2
    ) -> Bool {
        let recent = Array(values.suffix(3))
        guard recent.count == 3 else { return false }
        return recent.last! >= baseline && recent.last! - recent.first! >= requiredUptick
    }
}
