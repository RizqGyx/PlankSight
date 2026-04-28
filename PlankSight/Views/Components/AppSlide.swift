import SwiftUI

struct AppSlide: View {
    let title: String?
    let image: String
    let infoTitle: String
    let infoSubtitle: String

    var body: some View {
        VStack(spacing: 10) {
            // Main Illustration area
            ZStack(alignment: .topLeading) {
                Color.bgCard
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18).stroke(
                            Color.borderMain,
                            lineWidth: 1
                        )
                    )

                ZStack {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)

                    VStack {
                        HStack {
                            // HIG Caption 2: 11pt Semibold (illus-label)
                            Text(title ?? "Langkah 1 · Setup Kamera")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.textBody)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 3)
                                .background(Color.bgInput)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5).stroke(
                                        Color.borderMain,
                                        lineWidth: 1
                                    )
                                )
                            Spacer()
                        }
                        .padding(12)

                        Spacer()
                    }
                }
                .frame(maxHeight: .infinity)
            }

            // Info Card
            HStack(alignment: .top, spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(Color.brandBg)
                        .frame(width: 38, height: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 11).stroke(
                                Color.brandBorder,
                                lineWidth: 1
                            )
                        )

                    Image(systemName: "info.circle")
                        .foregroundColor(.brand)
                        .font(.system(size: 16, weight: .regular))
                }

                VStack(alignment: .leading, spacing: 3) {
                    // HIG Footnote: 13pt Semibold (info-strong)
                    Text(infoTitle)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    // HIG Caption 1: 12pt Regular (info-sub)
                    Text(infoSubtitle)
                        .font(.caption)
                        .foregroundColor(.textCaption)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                Spacer()
            }
            .padding(14)
            .background(Color.bgCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(
                    Color.borderMain,
                    lineWidth: 1
                )
            )
        }
        .padding(.horizontal)
    }
}

struct AppSlide1: View {
    var body: some View {
        AppSlide(
            title: "Langkah 1 - Beranda & Waktu Target",
            image: "Panduan1",
            infoTitle: "Pilih Durasi",
            infoSubtitle:
                "Selamat datang di PlankSight! Di halaman beranda, pilih durasi plank yang ingin kamu capai. Mulai dari yang kecil (20-30 detik) dan tingkatkan setiap hari!"
        )
    }
}
struct AppSlide2: View {
    var body: some View {
        AppSlide(
            title: "Langkah 2 - Rotasi Landscape",
            image: "Panduan2",
            infoTitle: "Putar HP Horizontal",
            infoSubtitle:
                "Sebelum memulai, putar HP kamu ke posisi landscape (horizontal). Aplikasi akan otomatis meminta kamu memutar layar jika belum benar."
        )
    }
}
struct AppSlide3: View {
    var body: some View {
        AppSlide(
            title: "Langkah 3 - Posisi dalam Frame",
            image: "Panduan3",
            infoTitle: "Letakkan HP & Posisikan Tubuh",
            infoSubtitle:
                "Letakkan HP di lantai menghadap ke depan. Posisikan dirimu sejauh ±1-1,5 meter dari kamera agar seluruh tubuhmu terlihat dalam frame."
        )
    }
}
struct AppSlide4: View {
    var body: some View {
        AppSlide(
            title: "Langkah 4 - Postur Plank yang Benar",
            image: "Panduan4",
            infoTitle: "Ambil Posisi Plank",
            infoSubtitle:
                "Tubuh lurus, pinggang tidak terlalu rendah atau tinggi. Timer belum akan berjalan sampai posisi plank kamu terdeteksi benar oleh sistem."
        )
    }
}
struct AppSlide5: View {
    var body: some View {
        AppSlide(
            title: "Langkah 5 - Timer Otomatis & Feedback",
            image: "Panduan5",
            infoTitle: "Timer Mulai Otomatis",
            infoSubtitle:
                "Begitu posisi plank terdeteksi benar, timer langsung mulai! Jika posisi salah, kamu akan dengar panduan suara & notifikasi - tapi timer tetap berjalan!"
        )
    }
}

struct PlankSlide1: View {
    var body: some View {
        AppSlide(
            title: "Metrik 1 - Kepala",
            image: "Kepala",
            infoTitle: "Sejajar Tulang Punggung",
            infoSubtitle: "Jangan mendongak atau menunduk terlalu dalam."
        )
    }
}
struct PlankSlide2: View {
    var body: some View {
        AppSlide(
            title: "Metrik 2 - Punggung",
            image: "Punggung",
            infoTitle: "Lurus Rata",
            infoSubtitle: "Hindari punggung yang melengkung atau membungkuk."
        )
    }
}
struct PlankSlide3: View {
    var body: some View {
        AppSlide(
            title: "Metrik 3 - Pinggul",
            image: "Pinggul",
            infoTitle: "Tidak Terlalu Turun",
            infoSubtitle:
                "Jaga agar pinggul tidak ambles ke bawah atau terlalu menungging."
        )
    }
}
struct PlankSlide4: View {
    var body: some View {
        AppSlide(
            title: "Metrik 4 - Lutut",
            image: "Lutut",
            infoTitle: "Lurus Tidak Menekuk",
            infoSubtitle:
                "Pastikan lutut tidak tertekuk dan tetap lurus selama gerakan plank."
        )
    }
}
struct PlankSlide5: View {
    var body: some View {
        AppSlide(
            title: "Metrik 5 - Siku",
            image: "Siku",
            infoTitle: "Siku Tepat di Bawah Bahu",
            infoSubtitle:
                "Pastikan siku sejajar tepat di bawah bahu. Lengan bawah harus sejajar dan tegak lurus ke depan, bukan melebar keluar."
        )
    }
}

#Preview {
    AppSlide1()
}
