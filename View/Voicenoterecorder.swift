import SwiftUI
import AVFoundation
import Combine
import Supabase

// ═══════════════════════════════════════════════
// MARK: - Voice Note Recorder (Parent → Child)
// ═══════════════════════════════════════════════

struct VoiceNoteRecorder: View {
    @Binding var voiceNoteUrl: String?
    @StateObject private var recorder = AudioRecorderManager()
    @State private var permissionDenied = false

    var body: some View {
        VStack(spacing: 12) {

            // Status label
            Group {
                if permissionDenied {
                    Text("⚠️ Microphone access denied — check Settings")
                        .foregroundColor(Color(hex: "E05555"))
                } else if recorder.isUploading {
                    Text("Uploading…")
                        .foregroundColor(.white.opacity(0.8))
                } else if recorder.uploadFailed {
                    Text("⚠️ Upload failed — note not attached")
                        .foregroundColor(Color(hex: "E05555"))
                } else if recorder.isDone && voiceNoteUrl != nil {
                    Text("✅ Voice note ready to send")
                        .foregroundColor(Color(hex: "4CAF50"))
                } else if recorder.isDone {
                    Text("✅ Recorded — will send with transfer")
                        .foregroundColor(Color(hex: "4CAF50"))
                } else if recorder.isRecording {
                    Text("Recording… \(recorder.secondsLeft)s left")
                        .foregroundColor(Color(hex: "E05555"))
                } else {
                    Text("Tap mic to record (max 40 sec)")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .font(.system(size: 13, weight: .medium))
            .multilineTextAlignment(.center)

            HStack(spacing: 20) {

                // Record / Stop button
                Button {
                    if recorder.isRecording {
                        recorder.stopRecording { url in
                            guard let url else { return }
                            recorder.isUploading = true
                            Task {
                                let result = await uploadAudio(url)
                                await MainActor.run {
                                    recorder.isUploading = false
                                    if let result {
                                        voiceNoteUrl = result
                                    } else {
                                        // Upload failed but recording exists locally
                                        recorder.uploadFailed = true
                                    }
                                }
                            }
                        }
                    } else if !recorder.isDone {
                        checkPermissionAndRecord()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                recorder.isRecording ? Color(hex: "E05555") :
                                recorder.isDone      ? Color.nafTextGray.opacity(0.4) :
                                                       Color(hex: "2D6DAB")
                            )
                            .frame(width: 56, height: 56)
                        if recorder.isUploading {
                            ProgressView().tint(.white).scaleEffect(0.9)
                        } else {
                            Image(systemName: recorder.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(recorder.isDone || recorder.isUploading || permissionDenied)

                // Playback button
                if recorder.isDone {
                    Button { recorder.playback() } label: {
                        ZStack {
                            Circle().fill(Color(hex: "1B3A6B")).frame(width: 56, height: 56)
                            Image(systemName: recorder.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 22)).foregroundColor(.white)
                        }
                    }

                    // Re-record
                    Button {
                        recorder.reset()
                        voiceNoteUrl = nil
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "E05555").opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "E05555"))
                        }
                    }
                }
            }

            // Progress bar while recording
            if recorder.isRecording {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "E05555"))
                            .frame(width: geo.size.width * CGFloat(40 - recorder.secondsLeft) / 40)
                    }
                }
                .frame(height: 6)
                .animation(.linear(duration: 1), value: recorder.secondsLeft)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(hex: "1B3A6B"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // ── Check mic permission safely (iOS 16 compatible) ──
    private func checkPermissionAndRecord() {
        let session = AVAudioSession.sharedInstance()
        let status  = session.recordPermission
        print("🎙️ Mic permission status: \(status.rawValue)")

        switch status {
        case .granted:
            print("🎙️ Permission granted — starting recording")
            recorder.startRecording()
        case .denied:
            print("🎙️ Permission denied")
            permissionDenied = true
        case .undetermined:
            print("🎙️ Permission undetermined — requesting")
            session.requestRecordPermission { granted in
                print("🎙️ Permission response: \(granted)")
                DispatchQueue.main.async {
                    if granted {
                        self.recorder.startRecording()
                    } else {
                        self.permissionDenied = true
                    }
                }
            }
        @unknown default:
            recorder.startRecording()
        }
    }

    // ── Upload to Supabase Storage ────────────────────────
    private func uploadAudio(_ fileUrl: URL) async -> String? {
        do {
            let data = try Data(contentsOf: fileUrl)
            let name = "voice_\(UUID().uuidString).m4a"

            try await supabase.storage
                .from("voice-notes")
                .upload(name, data: data, options: FileOptions(contentType: "audio/m4a"))

            let publicUrl = try supabase.storage
                .from("voice-notes")
                .getPublicURL(path: name)

            return publicUrl.absoluteString
        } catch {
            print("❌ uploadAudio: \(error)")
            return nil
        }
    }
}

// ═══════════════════════════════════════════════
// MARK: - AudioRecorderManager
// ═══════════════════════════════════════════════

@MainActor
final class AudioRecorderManager: NSObject, ObservableObject {

    @Published var isRecording  = false
    @Published var isPlaying    = false
    @Published var isDone       = false
    @Published var isUploading  = false
    @Published var uploadFailed = false
    @Published var secondsLeft  = 40

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer:   AVAudioPlayer?
    private var countdownTimer: Timer?
    private(set) var recordingUrl: URL?
    private var onStop: ((URL?) -> Void)?

    func startRecording() {
        print("🎙️ startRecording called")
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            print("🎙️ Audio session activated")

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("vnote_\(UUID().uuidString).m4a")
            recordingUrl = url
            print("🎙️ Recording to: \(url)")

            let settings: [String: Any] = [
                AVFormatIDKey:            Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey:          44100,
                AVNumberOfChannelsKey:    1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            let started = audioRecorder?.record() ?? false
            print("🎙️ recorder.record() returned: \(started)")
            isRecording = true
            secondsLeft = 40
            startCountdown()
        } catch {
            print("❌ startRecording error: \(error)")
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        onStop = completion
        audioRecorder?.stop()
        countdownTimer?.invalidate()
        countdownTimer = nil
        isRecording    = false
        isDone         = true
    }

    func playback() {
        guard let url = recordingUrl else { return }
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("❌ playback: \(error)")
        }
    }

    func reset() {
        audioPlayer?.stop()
        audioRecorder?.stop()
        countdownTimer?.invalidate()
        countdownTimer = nil
        isRecording    = false
        isPlaying      = false
        isDone         = false
        isUploading    = false
        uploadFailed   = false
        secondsLeft    = 40
        recordingUrl   = nil
        onStop         = nil
    }

    private func startCountdown() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.secondsLeft -= 1
                if self.secondsLeft <= 0 {
                    t.invalidate()
                    self.stopRecording(completion: self.onStop ?? { _ in })
                }
            }
        }
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(
        _ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            self.onStop?(flag ? self.recordingUrl : nil)
        }
    }
}

extension AudioRecorderManager: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.isPlaying = false }
    }
}

// ═══════════════════════════════════════════════
// MARK: - Voice Note Player (Child side)
// ═══════════════════════════════════════════════

struct VoiceNotePlayerButton: View {
    let url: String
    @State private var isPlaying = false
    @State private var isLoading = false
    @State private var player: AVPlayer?

    var body: some View {
        Button {
            if isPlaying {
                player?.pause()
                isPlaying = false
            } else {
                Task { await play() }
            }
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "2D6DAB").opacity(0.12))
                        .frame(width: 34, height: 34)
                    if isLoading {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "2D6DAB"))
                    }
                }
                Text(isPlaying ? "Stop voice note" : "▶ Play voice note")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "2D6DAB"))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "EBF4FF"))
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }

    private func play() async {
        guard let audioUrl = URL(string: url) else { return }
        isLoading = true
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ audio session: \(error)")
        }
        let item  = AVPlayerItem(url: audioUrl)
        let p     = AVPlayer(playerItem: item)
        player    = p
        isLoading = false
        isPlaying = true
        p.play()
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main) { _ in
            isPlaying = false
        }
    }
}
