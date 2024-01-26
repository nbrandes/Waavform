//
//  Waavform.swift
//  Waavform
//
//  Created by Nick Brandes on 1/23/24.
//

#if os(iOS)

import AVFoundation
import SwiftUI
import Waveform

@available(iOS 17.0, *)
private class WaavformModel: ObservableObject {
    
    @Published private(set) var duration: TimeInterval = 1.0
    @Published private(set) var currentTime: TimeInterval = 0.0
    @Published private(set) var timeNow: CMTime?
    var samples: SampleBuffer
    var player: AVPlayer?
    var sampleRate: Double?
    var channelCount: UInt32?
    private var timeObserver: Any?
    
    init(file: AVAudioFile? = nil, url: URL? = nil, category: AVAudioSession.Category) {
        let format = file?.fileFormat
        sampleRate = format?.sampleRate
        channelCount = format?.channelCount
        
        let fileSamples = file?.floatChannelData()!
        samples = SampleBuffer(samples: fileSamples?[0] ?? [0])
        
        setupAudioSession(category: category)
        player = AVPlayer(url: url ?? URL(filePath: ""))
        addPeriodicTimeObserver()
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 1000)
        timeObserver = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main) { [weak self] time in
            guard let self else { return }
            currentTime = time.seconds
            timeNow = time
            duration = player?.currentItem?.duration.seconds ?? 0.0
        }
    }
    
    private func removePeriodicTimeObserver() {
        guard let timeObserver else { return }
        player?.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }
    
    deinit {
        removePeriodicTimeObserver()
    }
    
    var progress: Double {
        return currentTime / duration
    }
    
    var durationString: String {
        var durationValue = 0.0
        if !(duration.isNaN || duration.isInfinite) {
            durationValue = duration
        }
        let duration = secondsToHoursMinutesSeconds(Int(durationValue))
        return "\(String(format: "%02d", duration.1)) : \(String(format: "%02d", duration.2))"
    }
    
    var curentTimeString: String {
        let time = secondsToHoursMinutesSeconds(Int(currentTime))
        return "\(String(format: "%02d", time.1)) : \(String(format: "%02d", time.2))"
    }
    
    private func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func setupAudioSession(category: AVAudioSession.Category = .playback) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("error setting up audio session")
        }
    }
}

@available(iOS 17.0, *)
@available(macOS 14.0, *)
public struct Waavform: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject fileprivate var model: WaavformModel
    @State var start = 0.0
    @State var length = 1.0
    @State var size = CGSize(width: 1.0, height: 2.0)
    @State var seekTime: CGFloat = 0.0
    @State var isSeeking = false
    @State var seekingLocation: Double = 0
    @State var isPlaying: Bool = false
    @State var isScrolling: Bool = false
    @State var scrollDragOffset = 0
    @State var preRollDragPosition: CGFloat = 0.0
    @State var isDragging = false
    
    var cursor: Color = .blue
    var playhead: Color = .red
    var progress: Color = .blue
    var backing: Color = .gray
    var timeText: Color = .white
    var timeBg: Color = .black
    var control: Color = .black
    var showTransport: Bool = true
    var showScroll: Bool = true
    
    var preRollSamples: Int {
        return getLength() / 2
    }
    
    var playheadPosition: CGFloat {
        if preRoll() < preRollSamples && isScrolling {
            if isDragging {
                return preRollDragPosition
            }
            let pos = Double(model.samples.count) / Double(getLength())
            let scaledPosition = CGFloat(pos * model.progress * size.width + Double(scrollDragOffset))
            return CGFloat(scaledPosition)
        }
        return CGFloat(model.progress * size.width)
    }
    
    public enum ViewType {
        case scroll, linear
    }
    
    public init(audio: String,
                type: String,
                progress: Color = Color(red: 0.290, green: 0.310, blue: 0.337),
                background: Color = Color(red: 0.875, green: 0.878, blue: 0.898),
                cursor: Color = .blue,
                playhead: Color = .red,
                timeText: Color = .white,
                timeBg: Color = .black,
                control: Color = .gray,
                category: AVAudioSession.Category = .playback,
                showTransport: Bool = true,
                showScroll: Bool = true,
                viewOnLoad: ViewType = .linear) {
        do {
            if let url = Bundle.main.url(forResource: audio, withExtension: type) {
                let file = try AVAudioFile(forReading: url)
                let theModel = WaavformModel(file: file, url: url, category: category)
                _model = StateObject(wrappedValue: theModel)
                self.showTransport = showTransport
                self.showScroll = showTransport
                self.cursor = cursor
                self.playhead = playhead
                self.progress = progress
                self.backing = background
                self.timeText = timeText
                self.timeBg = timeBg
                self.control = control
                
                
//                switch viewOnLoad {
//                case .linear:
//                    isScrolling = false
//                case .scroll:
//                    isScrolling = true
//                }
                return
            }
        } catch {
            print("Error initializing Waavform")
        }
        _model = StateObject(wrappedValue: WaavformModel(file: nil, url: nil, category: .playback))
    }
    
    func preRoll() -> Int {
        if isScrolling {
            if !(model.progress.isNaN || model.progress.isInfinite) {
                let percentage = model.progress
                let sampleCount = model.samples.count
                let start = Int(
                    (Double(sampleCount) / Double(getLength())) * percentage * Double(getLength())
                )
                
                let startVal = start + scrollDragOffset
                return startVal
            }
        }
        return 0
    }
    
    func getStart() -> Int {
        if isScrolling {
            if !(model.progress.isNaN || model.progress.isInfinite) {
                let percentage = model.progress
                let sampleCount = model.samples.count
                let start = Int(
                    (Double(sampleCount) / Double(getLength())) * percentage * Double(getLength())
                )
                
                let startVal = start - (getLength() / 2) + scrollDragOffset
                return startVal
            }
        }
        return Int(start * Double(model.samples.count - 1))
    }
    
    func getLength() -> Int {
        if isScrolling {
            // zoom level
            return 159157
        }
        return Int(length * Double(model.samples.count))
    }
    
    func getProgressWidth() -> CGFloat {
        if isScrolling {
            if preRoll() < preRollSamples {
                return CGFloat(Double(model.samples.count) / Double(getLength()) * model.progress * size.width)
            }
            return size.width / 2
        }
        return CGFloat(model.progress * size.width)
    }
    
    public var body: some View {
        VStack {
            VStack {
                ZStack(alignment: .leading) {
                    // Full waveform
                    GeometryReader { geo in
                        Waveform(samples: model.samples,
                                 start: max(getStart(), 0),
                                 length: getLength())
                        .foregroundColor(backing)
                        .onAppear {
                            size = geo.size
                        }
                        .onChange(of: geo.size) {
                            size = geo.size
                        }
                    }
                    
                    // Progress waveform
                    Waveform(samples: model.samples,
                             start: max(getStart(), 0),
                             length: getLength())
                    .foregroundColor(progress)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: max(getProgressWidth(), 0))
                    }
                    
                    // Seeking cursor
                    if isSeeking {
                        if !isScrolling {
                            Rectangle()
                                .fill(cursor)
                                .frame(width: 1, height: size.height)
                                .position(x: seekingLocation, y: size.height/2)
                            
                            Rectangle()
                                .fill(cursor)
                                .opacity(0.15)
                                .frame(width: max(seekingLocation - playheadPosition, 0) * 2 , height: size.height)
                                .position(x: playheadPosition, y: size.height/2)
                                .mask(Rectangle().padding(.leading, CGFloat(
                                    (model.progress * size.width)
                                )))
                        }
                    }
                    
                    // Playhead cursor
                    ZStack {
                        if !isScrolling {
                            Rectangle()
                                .fill(playhead)
                                .frame(width: 1, height: size.height)
                                .position(x: playheadPosition, y: size.height / 2)
                            ZStack {
                                // Current time
                                Rectangle()
                                    .fill(timeBg)
                                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
                                
                                Text("\(model.curentTimeString)")
                                    .foregroundColor(timeText)
                                    .font(.footnote)
                            }
                            .frame(width: 50, height: 4)
                            .position(x: playheadPosition, y: size.height / 2)
                        } else {
                            if preRoll() < preRollSamples && playheadPosition < size.width / 2 {
                                Rectangle()
                                    .fill(playhead)
                                    .frame(width: 1, height: size.height)
                                    .position(x: playheadPosition, y: size.height / 2)
                                ZStack {
                                    // Current time
                                    Rectangle()
                                        .fill(timeBg)
                                        .clipShape(RoundedRectangle(cornerRadius: 4.0))
                                    
                                    Text("\(model.curentTimeString)")
                                        .foregroundColor(timeText)
                                        .font(.footnote)
                                }
                                .frame(width: 50, height: 4)
                                .position(x: playheadPosition, y: size.height / 2)
                            } else {
                                Rectangle()
                                    .fill(playhead)
                                    .frame(width: 1, height: size.height)
                                    .position(x: size.width / 2, y: size.height / 2)
                                ZStack {
                                    // Current time
                                    Rectangle()
                                        .fill(timeBg)
                                        .clipShape(RoundedRectangle(cornerRadius: 4.0))
                                    
                                    Text("\(model.curentTimeString)")
                                        .foregroundColor(timeText)
                                        .font(.footnote)
                                }
                                .frame(width: 50, height: 4)
                                .position(x: size.width / 2, y: size.height / 2)
                            }
                        }
                    }
                    
                    ZStack {
                        // Duration
                        Rectangle()
                            .fill(timeBg)
                            .clipShape(RoundedRectangle(cornerRadius: 4.0))
                        Text("\(model.durationString)")
                            .foregroundColor(timeText)
                            .font(.footnote)
                    }
                    .frame(width: 50, height: 4)
                    .position(x: size.width, y: size.height / 2)
                }
                
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if !isScrolling {
                                seekingLocation = gesture.location.x
                                seekTime = (gesture.location.x / size.width) * model.duration
                                isSeeking = true
                            } else {
                                if isPlaying {
                                    model.player?.pause()
                                }
                                let percentage = gesture.translation.width / size.width
                                scrollDragOffset = Int(percentage * CGFloat(getLength()))
                                
                                if preRoll() < preRollSamples && isScrolling {
                                    isDragging = true
                                    preRollDragPosition = gesture.location.x
                                }
                            }
                        }
                        .onEnded { gesture in
                            if !isScrolling {
                                seekTime = (gesture.location.x / size.width) * model.duration
                                model.player?.seek(to: CMTimeMakeWithSeconds(seekTime, preferredTimescale: 1))
                                isSeeking = false
                            } else {
                                let percentage = gesture.translation.width / size.width
                                scrollDragOffset = Int(percentage * CGFloat(getLength()))
                                if let sampleRate = model.sampleRate {
                                    let offsetSeconds = Double(scrollDragOffset) / sampleRate * 100
                                    if let player = model.player, let timeNow = model.timeNow {
                                        let newTime = timeNow + CMTimeMake(value: Int64(offsetSeconds), timescale: 100)
                                        player.seek(to: newTime)
                                    }
                                }
                                scrollDragOffset = 0
                                isDragging = false
                                if isPlaying {
                                    model.player?.play()
                                }
                            }
                        }
                )
                .onTapGesture { position in
                    if !isScrolling {
                        seekTime = (position.x / size.width) * model.duration
                        model.player?.seek(to: CMTimeMakeWithSeconds(seekTime, preferredTimescale: 1))
                        if !isPlaying {
                            play()
                        }
                    }
                }
            }
            
            if showTransport {
                HStack {
                    HStack {
                        if !isPlaying {
                            // Play
                            Button {
                                play()
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .tint(control)
                            .buttonStyle(.bordered)
                            .font(.title2)
                        } else {
                            // Pause
                            Button {
                                pause()
                            } label: {
                                Image(systemName: "pause.fill")
                                
                            }
                            .tint(cursor)
                            .buttonStyle(.bordered)
                            .font(.title2)
                        }
                        // Stop
                        Button {
                            stop()
                        } label: {
                            Image(systemName: "stop.fill")
                        }
                        .tint(control)
                        .buttonStyle(.bordered)
                        .font(.title2)
                    }
                    Spacer()
                    if showScroll {
                        Button(isScrolling ? "Linear" : "Scroll") {
                            toggleScroll()
                        }
                    }
                }
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: AVPlayerItem.didPlayToEndTimeNotification)) { _ in
            self.stop()
        }
    }
    
    public func toggleScroll() {
        isScrolling = !isScrolling
    }
    
    public func play() {
        model.player?.play()
        isPlaying = true
        scrollDragOffset = 0
    }
    
    public func pause() {
        model.player?.pause()
        isPlaying = false
    }
    
    public func stop() {
        model.player?.pause()
        model.player?.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1))
        model.player?.play()
        model.player?.pause()
        isPlaying = false
        scrollDragOffset = 0
    }
}


#endif
