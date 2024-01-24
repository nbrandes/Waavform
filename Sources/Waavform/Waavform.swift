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
        let stereo = file?.floatChannelData()!
        samples = SampleBuffer(samples: stereo?[0] ?? [0])
        setupAudioSession(category: category)
        player = AVPlayer(url: url ?? URL(filePath: ""))
        addPeriodicTimeObserver()
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 10)
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
        let duration = secondsToHoursMinutesSeconds(Int(duration))
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
    
    var cursor: Color = .blue
    var playhead: Color = .red
    var progress: Color = .blue
    var backing: Color = .gray
    var timeText: Color = .white
    var timeBg: Color = .black
    var control: Color = .black
    var showTransport: Bool = true
    var showScroll: Bool = true
    
    var playheadPosition: CGFloat {
        return CGFloat(model.progress * size.width)
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
                showScroll: Bool = true) {
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
                return
            }
        } catch {
            print("Error initializing Waavform")
        }
        _model = StateObject(wrappedValue: WaavformModel(file: nil, url: nil, category: .playback))
    }
    
    func getStart() -> Int {
        if isScrolling {
            let percentage = model.progress
            let sampleCount = model.samples.count
            let start = Int(
                (Double(sampleCount) / Double(getLength())) * percentage * Double(getLength())
            )
            return start - (getLength() / 2) + scrollDragOffset
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
                                 start: getStart() ,
                                 length: getLength())
                        .foregroundColor(progress)
                        .onAppear {
                            size = geo.size
                        }
                        .onChange(of: geo.size) {
                            size = geo.size
                        }
                    }
                    
                    // Progress waveform
                    Waveform(samples: model.samples,
                             start: getStart(),
                             length: getLength())
                    .foregroundColor(backing)
                    .mask(Rectangle().padding(.leading, getProgressWidth()))
                    
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
                                .frame(width: (seekingLocation - playheadPosition) * 2 , height: size.height)
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
                                        model.player?.seek(to: newTime)
                                    }
                                }
                                scrollDragOffset = 0
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
        isPlaying = false
        scrollDragOffset = 0
    }
}

#endif
