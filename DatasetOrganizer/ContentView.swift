import SwiftUI

struct ColorProgressBar: View {
    let value: Double
    let total: Double

    private var fraction: Double {
        total > 0 ? min(value / total, 1.0) : 0.0
    }

    private var barColor: Color {
        Color(hue: fraction * 0.33, saturation: 0.85, brightness: 0.88)
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(barColor)
                        .frame(width: geo.size.width * fraction, height: 12)
                        .animation(.easeInOut(duration: 0.3), value: fraction)
                }
            }
            .frame(height: 12)

            Text("Organizing Dataset... \(Int(value)) / \(Int(total))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct ContentView: View {
    @State private var viewModel = OrganizerViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.black.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("SwiftyForge")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(.rect(cornerRadius: 24))
                    .shadow(radius: 10)

                VStack(spacing: 8) {
                    Text("Dataset Organizer")
                        .font(.largeTitle)
                        .bold()

                    Text("by SwiftyForge")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    HStack {
                        Picker("File Format:", selection: $viewModel.targetExtension) {
                            ForEach(FileType.allCases) { fileType in
                                Text(".\(fileType.rawValue)").tag(fileType)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 250)
                        .disabled(viewModel.isProcessing)
                    }

                    HStack(spacing: 12) {
                        Button("1. Source Folder", action: viewModel.selectSourceFolder)
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing)

                        Text(viewModel.sourceURL?.lastPathComponent ?? "Not selected")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 150, alignment: .leading)
                            .lineLimit(1)
                    }

                    HStack(spacing: 12) {
                        Button("2. Dataset Folder", action: viewModel.selectDestinationFolder)
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing)

                        Text(viewModel.destURL?.lastPathComponent ?? "Not selected")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: 150, alignment: .leading)
                            .lineLimit(1)
                    }

                    Toggle(isOn: $viewModel.copyMode) {
                        Label(
                            viewModel.copyMode ? "Copy files (originals kept)" : "Move files (originals removed)",
                            systemImage: viewModel.copyMode ? "doc.on.doc" : "arrow.right.doc.on.clipboard"
                        )
                        .foregroundStyle(viewModel.copyMode ? .blue : .orange)
                    }
                    .toggleStyle(.switch)
                    .disabled(viewModel.isProcessing)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.copyMode)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 16))

                if viewModel.isProcessing {
                    ColorProgressBar(value: viewModel.progress, total: viewModel.totalFiles)
                        .padding(.horizontal, 40)
                }

                Button("Distribute Files", action: viewModel.organizeDataset)
                    .buttonStyle(.plain)
                    .padding(10)
                    .foregroundStyle(.white)
                    .background(
                        (viewModel.destURL != nil && viewModel.sourceURL != nil) ? Color.blue : Color.gray
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .disabled(viewModel.destURL == nil || viewModel.sourceURL == nil || viewModel.isProcessing)

                Text(viewModel.statusMessage)
                    .font(.footnote)
                    .foregroundStyle(viewModel.isProcessing ? .orange : .green)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if viewModel.showOpenFolder {
                    Button(action: viewModel.openDestinationFolder) {
                        Label("Open Dataset Folder", systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .padding(32)
            .frame(minWidth: 500, minHeight: 600)
            .onAppear {
                print("ContentView Appeared")
            }
        }
        .background(
            Gradient(colors: [.topBackground, .bottomBackground]))
    }
}

#Preview {
    ContentView()
}
