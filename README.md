# Waavform

A simple waveform based audio player, for SwiftUI.

<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/waavform_linear.png />

## Contents

- [Add the Package](#package)
- [Usage](#usage)
- [Functions](#functions)
- [Parameters](#parameters)
- [Examples](#examples)

## Package

### For Xcode Projects

File > Add Package Dependencies > Enter Package URL: https://github.com/nbrandes/Waavform

### For Swift Packages

Add a dependency in your `Package.swift`

```swift
.package(url: "https://github.com/nbrandes/Waavform.git"),
```

## Usage

First add an audio file to your project. 

Initialize `Waavform` with the name and the extension of the audio file.

```swift
Waavform(audio: "TheMoon", type: "mp3")
```

<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/scroll_edit_clip.gif />


## Parameters

`Waavform` can be customized with the following parameters 

Required: \
`audio: String` - name of the audio file 

`type: String` - extension of the audio file

Optional: \
`progress: Color` - waveform progress color 

`background: Color` - waveform background color 

`cursor: Color` - the selection cursor color 

`playhead: Color` - the playhead color 

`timeText: Color` - current time and duration time color 

`timeBg: Color` - current time and duration time background color 

`control: Color`- play/stop button tint color 

`category: AVAudioSession.Category` - category used for the session

`showTransport: Bool` - show or hide the play/stop controls 

`showScroll: Bool` - show or hide the linear/scroll control 

`viewOnLoad: ViewType` - which view to display initially (.linear / .scroll)



## Functions

Play - Start playing the audio
```swift
play()
```

Pause - Pause the audio
```swift
pause()
```

Stop - Stop the audio and go to the beginning
```swift
stop()
```

ToggleView - Switch between scroll/linear views
```swift
toggleView()
```


## Examples

An example of three players stacked vertically. 

```swift
import SwiftUI
import Waavform

struct ContentView: View {
    var body: some View {
        VStack {
            Waavform(audio: "Song1", type: "mp3", progress: .blue, playhead: .cyan, viewOnLoad: .scroll)
            Waavform(audio: "Song2", type: "mp3", progress: .orange, playhead: .cyan, viewOnLoad: .linear)
            Waavform(audio: "Song3", type: "mp3", progress: .red, playhead: .cyan)
        }
    }
}
```

Shows how to use `Waavform` with custom playback controls.

```swift
import SwiftUI
import Waavform

struct ContentView: View {
    @State var wave : Waavform?
    var body: some View {
        VStack {
            wave
            HStack {
                Button("Play") {
                    wave?.play()
                }
                .buttonStyle(.borderedProminent)
                Button("Pause") {
                    wave?.pause()
                }
                .buttonStyle(.borderedProminent)
                Button("Stop") {
                    wave?.stop()
                }
                .buttonStyle(.borderedProminent)
                Button("Mode") {
                    wave?.toggleView()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            wave = Waavform(audio: song.name, type: song.type, playhead: .cyan, showControls: false, viewOnLoad: .scroll)
        }
    }
}
```
