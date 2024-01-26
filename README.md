# Waavform

A simple waveform based audio player, for SwiftUI.

<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/waavform.gif />

## Contents

- [Add the Package](#package)
- [Usage](#usage)
- [Parameters](#parameters)
- [Example](#example)

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
<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/waavform_stacks.PNG width=300 align="right"/>
Required: \
`audio: String` - name of the audio file \
`type: String` - extension of the audio file

Optional: \
`progress: Color` - waveform progress color - (Default Color(red: 0.290, green: 0.310, blue: 0.337))  \
`background: Color` - waveform background color - (Default Color(red: 0.875, green: 0.878, blue: 0.898)) \
`cursor: Color` - the selection cursor color - (Default .blue) \
`playhead: Color` - the playhead color - (Default .red) \
`timeText: Color` - current time and duration time color - (Default .white) \
`timeBg: Color` - current time and duration time background color - (Default .black) \
`control: Color`- play/stop button tint color - (Default .gray) 
                                    
`category: AVAudioSession.Category` - (Default .playback) - category used for the AVAudioSession \
`showTransport: Bool` - (Default true) - show or hide the play/stop controls \
`showScroll: Bool` - (Default true) - show or hide the linear/scroll control

## Example

```swift
import SwiftUI
import Waavform

struct ContentView: View {
    var body: some View {
        VStack {
            Text("The Moon")
            Text("Uberkazoo")
                .font(.caption2)
            Waavform(audio: "TheMoon", type: "mp3", progress: .blue, playhead: .cyan)
            Text("Body High")
            Text("Floydwhoelse")
                .font(.caption2)
            Waavform(audio: "BodyHigh", type: "mp3", progress: .blue, playhead: .cyan)
            Text("Blue Goo")
            Text("GLotus")
                .font(.caption2)
            Waavform(audio: "Bluegoo", type: "mp3", progress: .blue, playhead: .cyan)
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    ContentView()
}

```
