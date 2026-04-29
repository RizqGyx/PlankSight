import Charts
import SwiftUI

struct SetelWaktuView: View {
    @StateObject private var viewModel = SetelWaktuViewModel()
    @EnvironmentObject var appRouter: AppRouter
    @State private var showTargetOptions = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PlankSight")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                        Text(viewModel.headerSubtitle)
                            .font(.footnote)
                            .foregroundColor(.textCaption)
                    }
                    Spacer()
                    Button(action: { appRouter.goToPanduan() }) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.textCaption)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // MARK: - Day Indicator
                        DayIndicatorView(indicators: viewModel.displayedIndicators)

                        // MARK: - Progress Chart
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Aktivitas Minggu Ini")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Button(action: { appRouter.navigate(to: .history) }) {
                                    Text("Riwayat")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.brand)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text(viewModel.formatWeeklyTotal(viewModel.weeklyTotal))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.brand)
                                    Text("minggu ini")
                                        .font(.caption)
                                        .foregroundColor(.textCaption)
                                }

                                Text("Detik form benar per hari")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.textCaption)
                                    .padding(.bottom, 2)

                                Chart(viewModel.chartData) { data in
                                    BarMark(
                                        x: .value("Hari", data.day),
                                        y: .value("Detik", data.duration)
                                    )
                                    .foregroundStyle(
                                        data.duration > 0
                                            ? Color.brand.gradient
                                            : Color.textMuted.opacity(0.12).gradient
                                    )
                                    .cornerRadius(6)
                                    .annotation(position: .top, alignment: .center, spacing: 3) {
                                        if data.duration > 0 {
                                            Text("\(data.duration)s")
                                                .font(.system(size: 9, weight: .bold))
                                                .foregroundColor(.brand)
                                        }
                                    }
                                }
                                .chartYAxis(.hidden)
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel {
                                            if let s = value.as(String.self) {
                                                Text(s)
                                                    .font(.caption2)
                                                    .foregroundColor(.textCaption)
                                            }
                                        }
                                    }
                                }
                                .frame(height: 160)
                            }
                            .padding(16)
                            .background(Color.bgCard)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20).stroke(Color.borderMain, lineWidth: 1)
                            )
                        }

                        // MARK: - Motivation Card
                        MotivationCardView(
                            card: MotivationCardHelper.generateMotivationCard(
                                lastSessionDate: viewModel.completedToday ? Date() : Date().addingTimeInterval(-86400),
                                streak: viewModel.streak,
                                today: viewModel.completedToday
                            )
                        )

                        // MARK: - Gamification (Badges)
                        VStack(alignment: .leading, spacing: 16) {
                            let totalObtained = viewModel.badgeGroups.reduce(0) { $0 + $1.obtainedCount }
                            let totalBadges   = viewModel.badgeGroups.reduce(0) { $0 + $1.badges.count }

                            HStack(alignment: .firstTextBaseline) {
                                Text("Pencapaianmu")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                                Text("\(totalObtained)/\(totalBadges) terbuka")
                                    .font(.caption)
                                    .foregroundColor(.textCaption)
                            }

                            VStack(spacing: 20) {
                                ForEach(viewModel.badgeGroups) { group in
                                    BadgeGroupSection(group: group)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }

                // MARK: - Bottom CTA
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Mulai Plank Sekarang",
                        iconName: "play.circle.fill"
                    ) {
                        appRouter.navigate(to: .camera(duration: nil))
                    }
                    .padding(.horizontal)

                    Button(action: { showTargetOptions = true }) {
                        Text("Tetapkan Target Waktu Khusus")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.brand)
                    }
                }
                .padding(.bottom, 16)
                .background(Color.bgPrimary)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            forcePortrait()
            viewModel.loadDashboardData()
        }
        .sheet(isPresented: $showTargetOptions) {
            TargetWaktuSheet(viewModel: viewModel, appRouter: appRouter)
                .presentationDetents([.fraction(0.65)])
        }
    }

    // MARK: - Orientation

    private func forcePortrait() {
        AppDelegate.orientationLock = .portrait
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        if #available(iOS 16.0, *) {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
}

#Preview {
    SetelWaktuView()
        .environmentObject(AppRouter())
}
