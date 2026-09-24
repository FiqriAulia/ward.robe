import AppKit
import SwiftUI
import UniformTypeIdentifiers
import WardrobeCore

/// Form nama/deskripsi/foto, dipakai Input dan Edit.
struct ClothingForm: View {
    @Binding var name: String
    @Binding var notes: String
    @Binding var photo: PreparedPhoto?
    var existingThumbnail: Data?
    var namePlaceholder = "Dapat berupa merk"
    var errors: [String] = []
    let submitTitle: String
    let onSubmit: () -> Void

    @State private var photoBusy = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ErrorList(messages: errors)

            Text("Nama :")
            TextField(namePlaceholder, text: $name)
                .textFieldStyle(.roundedBorder)

            Text("Deskripsi :")
            TextEditor(text: $notes)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(6)
                .frame(height: 130)
                .background(RoundedRectangle(cornerRadius: 6).fill(.white))

            Text("Foto :")
            PhotoDropZone(photo: $photo, isBusy: $photoBusy, existingThumbnail: existingThumbnail)

            HStack {
                Spacer()
                Button(submitTitle, action: onSubmit)
                    .buttonStyle(PillButtonStyle())
                    .keyboardShortcut(.defaultAction)
                    .disabled(photoBusy)
            }
        }
        .frame(width: 520)
    }
}

/// Area foto: klik untuk memilih file, atau tarik foto dari Finder/Photos ke sini.
struct PhotoDropZone: View {
    @Binding var photo: PreparedPhoto?
    @Binding var isBusy: Bool
    var existingThumbnail: Data?

    @State private var showImporter = false
    @State private var isTargeted = false
    @State private var errorMessage: String?

    private var previewData: Data? { photo?.thumbnail ?? existingThumbnail }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isTargeted ? 0.9 : 0.6))
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(isTargeted ? Color.wardrobeDark : Color.gray)

                if isBusy {
                    ProgressView()
                } else if let previewData, let image = NSImage(data: previewData) {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 28))
                        Text("Tarik foto ke sini, atau klik untuk memilih")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .frame(height: 170)
            .contentShape(Rectangle())
            .onTapGesture { showImporter = true }
            .onDrop(of: [.fileURL, .image], isTargeted: $isTargeted, perform: handleDrop)
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.image]) { result in
                if case .success(let url) = result {
                    process { try PhotoProcessor.prepare(fileAt: url) }
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(Color(red: 0.55, green: 0.12, blue: 0.12))
            } else if previewData != nil {
                Text("Klik atau tarik foto lain untuk mengganti.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            _ = provider.loadObject(ofClass: URL.self) { url, _ in
                guard let url else { return }
                Task { @MainActor in process { try PhotoProcessor.prepare(fileAt: url) } }
            }
            return true
        }

        provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, _ in
            guard let data else { return }
            Task { @MainActor in process { try PhotoProcessor.prepare(data) } }
        }
        return true
    }

    /// Proses foto di background supaya UI tidak macet untuk foto besar.
    private func process(_ work: @escaping @Sendable () throws -> PreparedPhoto) {
        isBusy = true
        errorMessage = nil
        Task {
            let result = await Task.detached(priority: .userInitiated) { Result(catching: work) }.value
            isBusy = false
            switch result {
            case .success(let prepared):
                photo = prepared
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

/// Picker jenis pakaian (segmented).
struct KindPicker: View {
    @Binding var kind: ClothingKind

    var body: some View {
        Picker("Jenis", selection: $kind) {
            ForEach(ClothingKind.allCases) { kind in
                Text(kind.label).tag(kind)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .frame(width: 360)
    }
}
