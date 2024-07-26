import SwiftUI

struct ProgressState {
    var progress: Double {
        didSet {
            progress = min(1, max(0, progress))
        }
    }
    
    init(progress: Double = 0.0) {
        self.progress = min(1, max(0, progress))
    }
}
