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
            Text("Tap a day to view or edit it.").font(.caption).foregroundStyle(palette.secondary)
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
        return Button { selected = date; presented = true } label: {
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
        return ScrollView {
            VStack(spacing: 18) {
                Text(date, format: .dateTime.weekday(.wide).month(.wide).day()).font(WorldType.title).multilineTextAlignment(.center)
                Text(done ? completedCopy : isToday ? "Your next small win" : past ? "No completion recorded" : "A day to look forward to")
                    .font(.headline).multilineTextAlignment(.center)
                Text(done ? rewardCopy : past ? "Forgot to log it? You can update this day." : isToday ? "Head to Today for your daily ritual." : "Come back when this day arrives.")
                    .font(.body).foregroundStyle(palette.secondary).multilineTextAlignment(.center)
                if past {
                    Button(done ? "Remove completion" : "Add completion", role: done ? .destructive : nil) { confirm = true }
                        .buttonStyle(.bordered).controlSize(.large).accessibilityIdentifier("history-edit")
                }
                Button("Done") { presented = false }.frame(minHeight: 44)
            }.padding(28).frame(maxWidth: .infinity)
        }
        .foregroundStyle(palette.ink).background(palette.paper).tint(palette.accent)
        .presentationBackground(palette.paper)
        .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
        .confirmationDialog(done ? "Remove this completion?" : "Add this completion?", isPresented: $confirm, titleVisibility: .visible) {
            Button(done ? "Remove completion" : "Add completion", role: done ? .destructive : nil) {
                do { try edit(date, !done) } catch { failure = "Your change could not be saved. Please try again." }
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("Your streak and progress will update. You can change this again later.") }
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
            } else {
                if palette.tone == .morning {
                    a.books(-23,-7,palette); a.lamp(0,-27,palette)
                } else {
                    a.round(-40,-7,80,7,2,palette.wood)
                    a.books(-28,-16,palette); a.books(-16,-42,palette)
                    a.line([-30,0,-30,12,30,12,30,0],palette.woodEdge,3)
                }
            }
        }.accessibilityHidden(true)
    }
}

public struct UnlockGallery: View {
    public let total: Int
    public let thresholds: [Int]
    public let titles: [String]
    public let palette: WorldPalette
    @State private var selection: Int?
    @Environment(\.dynamicTypeSize) private var textSize
    public init(total: Int, thresholds: [Int], titles: [String], palette: WorldPalette) {
        self.total = total; self.thresholds = thresholds; self.titles = titles; self.palette = palette
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("A little more yours").font(WorldType.title)
            Text("Small rituals add up. Tap an object to explore.").font(.subheadline).foregroundStyle(palette.secondary)
            if textSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 18) { objects }
            } else {
                HStack(alignment: .top, spacing: 12) { objects }
            }
        }
        .alert(selection.map { titles[$0] } ?? "", isPresented: Binding(get: { selection != nil }, set: { if !$0 { selection = nil } })) {
            Button("Lovely", role: .cancel) { selection = nil }
        } message: {
            if let i = selection {
                Text(total >= thresholds[i] ? "Earned with \(thresholds[i]) completions. It now belongs in your space." : "\(max(0, thresholds[i] - total)) more completions to discover this detail. Any days count.")
            }
        }
    }
    private var objects: some View {
        ForEach(Array(thresholds.indices), id: \.self) { i in
            Button { selection = i } label: {
                VStack(spacing: 5) {
                    RewardObject(index: i, palette: palette).frame(height: 100).opacity(total >= thresholds[i] ? 1 : 0.5)
                    Text(titles[i]).font(.subheadline.weight(.semibold)).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                    Text(total >= thresholds[i] ? "Yours" : "\(total)/\(thresholds[i]) days").font(.caption).foregroundStyle(palette.secondary)
                }.frame(minWidth: 86, maxWidth: .infinity).contentShape(Rectangle())
            }.buttonStyle(.plain).foregroundStyle(palette.ink)
            .accessibilityLabel("\(titles[i]), \(total >= thresholds[i] ? "unlocked" : "unlocks at \(thresholds[i]) completions")")
            .accessibilityIdentifier("milestone-\(i)")
        }
    }
}
