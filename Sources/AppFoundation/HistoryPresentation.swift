import SwiftUI

public struct HistoryCalendar: View {
    public let today: Date
    public let completed: Set<String>
    public let key: (Date) -> String
    public let palette: WorldPalette
    public let completedCopy: String
    public let rewardCopy: String
    public let edit: (Date, Bool) throws -> Void
    @Binding public var presented: Bool
    @State private var expanded = false
    @Environment(\.dynamicTypeSize) private var textSize
    @ScaledMetric(relativeTo: .subheadline) private var diameter = 36
    @ScaledMetric(relativeTo: .caption) private var stripHeight = 90
    @State private var selected: Date?
    @State private var confirm = false
    @State private var failure: String?
    private var calendar: Calendar { var c = Calendar(identifier: .gregorian); c.timeZone = .autoupdatingCurrent; return c }

    public init(today: Date, completed: Set<String>, key: @escaping (Date) -> String,
                palette: WorldPalette, completedCopy: String, rewardCopy: String,
                presented: Binding<Bool>, edit: @escaping (Date, Bool) throws -> Void) {
        self.today = today; self.completed = completed; self.key = key; self.palette = palette
        self.completedCopy = completedCopy; self.rewardCopy = rewardCopy; _presented = presented; self.edit = edit
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(expanded ? "The last 28 days" : "Around today").font(WorldType.action)
                Spacer()
                Button(expanded ? "Show week" : "See more") { withAnimation(.snappy(duration: 0.25)) { expanded.toggle() } }
                    .font(.subheadline.weight(.semibold)).frame(minHeight: 44)
                    .accessibilityIdentifier("history-expand")
            }
            if expanded {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: textSize.isAccessibilitySize ? 3 : 7), spacing: 9) {
                    ForEach(days(-27...0), id: \.self) { day in dayButton(day) }
                }
            } else {
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(days(-3...3), id: \.self) { day in
                                dayButton(day).frame(width: max(diameter + 8, geometry.size.width / 7))
                            }
                        }
                    }.defaultScrollAnchor(.center)
                }.frame(height: stripHeight)
            }
        }
        .foregroundStyle(palette.ink).tint(palette.accent)
        .sheet(isPresented: $presented) {
            if let date = selected { detail(date) }
        }
    }
    private func days(_ offsets: ClosedRange<Int>) -> [Date] {
        offsets.compactMap { calendar.date(byAdding: .day, value: $0, to: calendar.startOfDay(for: today)) }
    }
    private func dayButton(_ date: Date) -> some View {
        let done = completed.contains(key(date))
        let isToday = calendar.isDate(date, inSameDayAs: today)
        let future = date > calendar.startOfDay(for: today)
        return Button { confirm = false; selected = date; presented = true } label: {
            VStack(spacing: 6) {
                Text(date, format: .dateTime.weekday(.narrow)).font(.caption.weight(.medium))
                ZStack {
                    Circle().fill(done ? palette.action : palette.wall).frame(width: diameter, height: diameter)
                    if isToday { Circle().stroke(palette.accent, lineWidth: 2).frame(width: diameter + 6, height: diameter + 6) }
                    Text(date, format: .dateTime.day()).font(.subheadline.weight(.semibold)).foregroundStyle(done ? Color.white : palette.ink)
                }.frame(height: diameter + 8)
                Image(systemName: done ? "checkmark" : future ? "minus" : isToday ? "circle.fill" : "circle")
                    .font(.system(size: 8, weight: .bold)).frame(height: 10)
            }.frame(minWidth: 44, minHeight: 80).contentShape(Rectangle())
        }.buttonStyle(.plain)
            .accessibilityLabel("\(date.formatted(date: .complete, time: .omitted)), \(isToday ? "today, " : "")\(done ? "completed" : future ? "upcoming" : "not recorded")")
            .accessibilityIdentifier(isToday ? "history-today" : key(date))
    }
    private func detail(_ date: Date) -> some View {
        let done = completed.contains(key(date))
        let past = date < calendar.startOfDay(for: today)
        let isToday = calendar.isDate(date, inSameDayAs: today)
        return GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 12)
                    VStack(spacing: 4) {
                        Text("\(date.formatted(.dateTime.weekday(.wide))) · \(date.formatted(.dateTime.month(.wide)))")
                            .font(.subheadline.weight(.medium)).foregroundStyle(palette.secondary)
                        Text(date, format: .dateTime.day())
                            .font(.system(.largeTitle, design: .rounded, weight: .bold)).monospacedDigit()
                    }.accessibilityElement(children: .combine)
                    ZStack {
                        VStack(spacing: 12) {
                            Text(done ? completedCopy : isToday ? "Your next small win" : past ? "No completion recorded" : "A day to look forward to")
                                .font(.headline)
                            Text(done ? rewardCopy : past ? "Did your ritual? Add it here." : isToday ? "Head to Today for your daily ritual." : "Come back when this day arrives.")
                                .font(.body).foregroundStyle(palette.secondary)
                        }.opacity(confirm ? 0 : 1).accessibilityHidden(confirm)
                        VStack(spacing: 12) {
                            Text(done ? "Remove this completion?" : "Add this completion?").font(.headline)
                            Text(palette.tone == .morning ? "Your streak and room will update. This is reversible." : "Your streak and workspace will update. This is reversible.")
                                .font(.body).foregroundStyle(palette.secondary)
                        }.opacity(confirm ? 1 : 0).accessibilityHidden(!confirm)
                    }.multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true).padding(.vertical, 12)
                    Spacer(minLength: 12)
                    VStack(spacing: 8) {
                        if past {
                            Button(done ? "Remove completion" : "Add completion", role: done ? .destructive : nil) {
                                if confirm {
                                    do { try edit(date, !done); confirm = false }
                                    catch { failure = "Your change could not be saved. Please try again." }
                                } else { confirm = true }
                            }
                            .buttonStyle(.bordered).controlSize(.large).accessibilityIdentifier("history-edit")
                        }
                        Button(confirm ? "Cancel" : "Done") {
                            if confirm { confirm = false } else { presented = false }
                        }.frame(minHeight: 44)
                    }
                }.padding(.horizontal, 28).padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .foregroundStyle(palette.ink).background(palette.paper).tint(palette.accent)
        .presentationBackground(palette.paper)
        .presentationDetents([.fraction(0.6), .large]).presentationDragIndicator(.visible)
        .alert("Couldn’t save", isPresented: Binding(get: { failure != nil }, set: { if !$0 { failure = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(failure ?? "") }
    }
}

public struct RewardObject: View {
    public let index: Int
    public let palette: WorldPalette
    public init(index: Int, palette: WorldPalette) { self.index = index; self.palette = palette }
    public var body: some View {
        Canvas { ctx, size in
            var c = ctx; let scale = min(size.width / 100, size.height / 120)
            c.translateBy(x: size.width / 2, y: size.height * 0.85); c.scaleBy(x: scale,y: scale)
            let a = Illustration(c)
            if index == 0 { a.plant(0,0,0.85,palette) }
            else if index == 1 {
                a.round(-36,-92,72,83,3,palette.woodEdge)
                a.round(-30,-86,60,71,1,palette.cream)
                a.oval(4,-78,19,19,palette.gold)
                a.polygon([-28,-25,-8,-60,13,-25],palette.cloth)
                a.polygon([-8,-17,14,-55,28,-17],palette.leaf)
                a.round(-41,-4,82,5,2,palette.wood)
            } else if index == 2 {
                if palette.tone == .morning {
                    a.books(-23,-7,palette); a.lamp(0,-27,palette)
                } else {
                    a.round(-40,-7,80,7,2,palette.wood)
                    a.books(-28,-16,palette); a.books(-16,-42,palette)
                    a.line([-30,0,-30,12,30,12,30,0],palette.woodEdge,3)
                }
            } else if index == 3 {
                if palette.tone == .morning {
                    a.round(-37,-65,74,54,8,palette.cloth)
                    a.round(-37,-65,74,16,5,palette.cream)
                    for x in stride(from: -28, through: 28, by: 14) {
                        a.line([CGFloat(x),-45,CGFloat(x),-4],palette.gold,2)
                    }
                    a.line([-30,-32,29,-32],palette.cream.opacity(0.5),2)
                } else {
                    a.round(-30,-88,62,81,5,palette.action)
                    a.round(-25,-83,57,71,3,palette.cream)
                    a.round(-30,-88,8,81,3,palette.woodEdge)
                    a.line([-12,-64,20,-64],palette.gold,3)
                    a.line([14,-80,14,-14],palette.cloth,3)
                    a.line([37,-70,37,-10],palette.gold,5)
                }
            } else {
                a.round(-42,-24,84,25,5,palette.wood)
                a.line([-37,-18,37,-18],palette.cream.opacity(0.5),2)
                for x: CGFloat in [-25,0,25] {
                    a.line([x,-23,x,-63],palette.leaf,2)
                    a.leaf(x,-39,-17,-18,palette.leaf)
                    a.leaf(x,-54,16,-18,palette.leaf)
                    a.oval(x-5,-72,10,10,palette.gold)
                }
            }
        }.accessibilityHidden(true)
    }
}

/// All rewards are presentation derived from existing completion totals, never stored.
public enum WorldRewards {
    public static let thresholds = [5, 10, 15, 20, 30]
    public static func nextSummary(total: Int, tone: WorldTone) -> String {
        guard let i = thresholds.firstIndex(where: { total < $0 }) else { return "Every detail earned" }
        return "Next: \(titles(tone)[i]) · \(thresholds[i] - total) to go"
    }
    public static func titles(_ tone: WorldTone) -> [String] {
        tone == .morning ? ["A green friend", "Wall print", "Reading corner", "Woven throw", "Window garden"]
                        : ["Desk plant", "Studio print", "Bookshelf", "Daybook", "Window garden"]
    }
}

@MainActor public struct UnlockGallery: View {
    public let total: Int
    public let thresholds: [Int]
    public let titles: [String]
    public let palette: WorldPalette
    public let onPresentationChange: (Bool) -> Void
    @State private var selection: Int?
    @Environment(\.dynamicTypeSize) private var textSize
    public init(total: Int, thresholds: [Int], titles: [String], palette: WorldPalette, onPresentationChange: @escaping (Bool) -> Void = { _ in }) {
        self.total = total; self.thresholds = thresholds; self.titles = titles; self.palette = palette
        self.onPresentationChange = onPresentationChange
    }
    private var next: Int { thresholds.indices.first { total < thresholds[$0] } ?? thresholds.count - 1 }
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { featuredArt; featuredCopy }
                VStack(alignment: .leading, spacing: 8) { featuredArt; featuredCopy }
            }
            Text("Your collection").font(.headline)
            if textSize.isAccessibilitySize {
                VStack(spacing: 20) { objects }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 20) { objects }
                        .padding(.vertical, 4)
                }.accessibilityIdentifier("reward-collection")
            }
        }
        .sheet(isPresented: Binding(get: { selection != nil }, set: { if !$0 { selection = nil } })) {
            if let i = selection {
                RewardDetail(index: i, title: titles[i], threshold: thresholds[i], total: total, palette: palette) { selection = nil }
            }
        }
        .onChange(of: selection) { _, value in onPresentationChange(value != nil) }
        .sensoryFeedback(.selection, trigger: selection)
    }
    private var featuredArt: some View {
        Button { selection = next } label: {
            RewardObject(index: next, palette: palette).frame(width: 105, height: 132)
        }.buttonStyle(CompanionPressStyle()).accessibilityLabel("Preview \(titles[next])")
            .accessibilityIdentifier("next-reward")
    }
    private var featuredCopy: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(total >= thresholds.last! ? "Made by your ritual" : "NEXT TO UNLOCK")
                .font(.caption.weight(.bold)).tracking(1).foregroundStyle(palette.floorSecondary)
            Text(titles[next]).font(WorldType.title).fixedSize(horizontal: false, vertical: true)
            Text(total >= thresholds.last! ? "Every detail earned." : "\(thresholds[next] - total) more \(palette.tone == .morning ? (thresholds[next] - total == 1 ? "morning" : "mornings") : (thresholds[next] - total == 1 ? "reset" : "resets"))")
                .font(.subheadline.weight(.medium)).foregroundStyle(palette.floorSecondary)
                .fixedSize(horizontal: false, vertical: true)
            ProgressView(value: Double(min(total, thresholds[next])), total: Double(thresholds[next]))
                .tint(palette.action).frame(maxWidth: 200).padding(.top, 5)
                .accessibilityLabel("Next reward").accessibilityValue("\(min(total, thresholds[next])) of \(thresholds[next]) completions")
        }
    }
    private var objects: some View {
        ForEach(Array(thresholds.indices), id: \.self) { i in
            Button { selection = i } label: {
                VStack(spacing: 5) {
                    RewardObject(index: i, palette: palette).frame(width: 94, height: 104)
                    Text(titles[i]).font(.subheadline.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
                    Text(total >= thresholds[i] ? "At home" : "\(thresholds[i]) days")
                        .font(.caption.weight(.medium)).foregroundStyle(palette.floorSecondary)
                }.multilineTextAlignment(.center).frame(width: textSize.isAccessibilitySize ? 230 : 108)
                    .contentShape(Rectangle())
            }.buttonStyle(CompanionPressStyle()).foregroundStyle(palette.ink)
                .accessibilityLabel("\(titles[i]), \(total >= thresholds[i] ? "unlocked" : "unlocks at \(thresholds[i]) completions")")
                .accessibilityIdentifier("milestone-\(i)")
        }
    }
}

/// A tangible next object replaces the old stack of instructions under Today.
@MainActor public struct RitualKeepsake: View {
    @State private var preview = false
    public let total: Int
    public let completed: Bool
    public let palette: WorldPalette
    public let undoTitle: String
    public let undo: () -> Void
    public let onPresentationChange: (Bool) -> Void
    public init(total: Int, completed: Bool, palette: WorldPalette, undoTitle: String, undo: @escaping () -> Void, onPresentationChange: @escaping (Bool) -> Void = { _ in }) {
        self.total = total; self.completed = completed; self.palette = palette; self.undoTitle = undoTitle; self.undo = undo
        self.onPresentationChange = onPresentationChange
    }
    private var next: Int { WorldRewards.thresholds.firstIndex { total < $0 } ?? 4 }
    public var body: some View {
        VStack(spacing: 4) {
            if completed {
                Text(palette.tone == .morning ? "Bed made. Day begun." : "Clear desk. Fresh perspective.")
                    .font(WorldType.title).multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button { preview = true } label: {
            HStack(spacing: 14) {
                RewardObject(index: next, palette: palette).frame(width: 64, height: 70)
                VStack(alignment: .leading, spacing: 3) {
                    Text(WorldRewards.titles(palette.tone)[next]).font(.headline)
                    Text(total >= 30 ? "Every detail earned." : "\(WorldRewards.thresholds[next] - total) to unlock")
                        .font(.subheadline).foregroundStyle(palette.floorSecondary)
                        .accessibilityIdentifier("today-next-unlock")
                }.fixedSize(horizontal: false, vertical: true)
            }.frame(maxWidth: .infinity)
            }.buttonStyle(CompanionPressStyle()).foregroundStyle(palette.ink)
                .accessibilityIdentifier("today-reward-preview")
            if completed {
                Button(undoTitle, role: .destructive, action: undo).font(.subheadline).frame(minHeight: 44)
            }
        }.padding(.horizontal, 26).padding(.vertical, 8)
            .onChange(of: preview) { _, value in onPresentationChange(value) }
            .sheet(isPresented: $preview) {
                RewardDetail(index: next, title: WorldRewards.titles(palette.tone)[next],
                    threshold: WorldRewards.thresholds[next], total: total, palette: palette) { preview = false }
            }
    }
}

/// Seven stitched leaves: a short challenge without another status card.
public struct RitualTrail: View {
    public let count: Int
    public let best: Int
    public let palette: WorldPalette
    public init(count: Int, best: Int, palette: WorldPalette) { self.count = count; self.best = best; self.palette = palette }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(count >= 7 ? "First seven: yours." : "Your first seven").font(WorldType.title)
            HStack(spacing: 10) {
                ForEach(0..<7) { i in
                    Canvas { c, size in
                        let a = Illustration(c)
                        let earned = i < count
                        a.line([3,size.height-3,size.width-3,3],palette.woodEdge.opacity(0.3),1.5)
                        if earned {
                            a.leaf(3,size.height-3,size.width-6,-size.height+6,palette.leaf)
                            a.line([5,size.height-5,size.width-6,6],palette.cream.opacity(0.55),1)
                        }
                    }.frame(maxWidth: 40).frame(height: 28)
                }
            }.accessibilityElement(children: .ignore)
                .accessibilityLabel("First seven completions").accessibilityValue("\(min(count, 7)) of 7, any days count")
            Text("\(min(count, 7))/7 · Any days count · Best streak \(best)")
                .font(.caption.weight(.medium)).foregroundStyle(palette.floorSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(.vertical, 6)
    }
}

private struct RewardDetail: View {
    let index: Int
    let title: String
    let threshold: Int
    let total: Int
    let palette: WorldPalette
    let dismiss: () -> Void
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    Spacer(minLength: 8)
                    RewardObject(index: index, palette: palette).frame(height: 160)
                    Text(title).font(WorldType.title)
                    Text(total >= threshold ? "Yours to enjoy" : "\(max(0, threshold - total)) more to make it yours")
                        .font(.headline).foregroundStyle(palette.accent)
                    Text(total >= threshold ? "Earned with \(threshold) completions." : "Unlocks at \(threshold) completions. Any days count.")
                        .font(.subheadline).foregroundStyle(palette.secondary)
                    Spacer(minLength: 8)
                    Button("Done", action: dismiss).font(.headline).frame(minHeight: 44)
                }.multilineTextAlignment(.center).padding(24)
                    .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }.foregroundStyle(palette.ink).background(palette.paper)
            .presentationDetents([.fraction(0.6), .large]).presentationDragIndicator(.visible)
    }
}
