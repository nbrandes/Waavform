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

## Parameters

`Waavform` can be initialized with the following parameters

Required: \
`audio: String` - name of the audio file \
`type: String` - extension of the audio file

Optional: \
`progress: Color` - (Default Color(red: 0.290, green: 0.310, blue: 0.337)) - waavform progress \
`background: Color` - (Default Color(red: 0.875, green: 0.878, blue: 0.898)) - waavform background \
`cursor: Color` - (Default .blue) - the selection cursor \
`playhead: Color` - (Default .red) - the playhead \
`timeText: Color` - (Default .white) - current time and duration time \
`timeBg: Color` - (Default .black) - current time and duration time background \
`control: Color`- (Default .gray) - play/stop button tint
                                    
`category: AVAudioSession.Category` - (Default .playback) - category used for the AVAudioSession \
`hideTransport: Bool` - (Default false) - show or hide the play/stop controls

## Example

```swift
import SwiftUI
import Waavform


struct ContentView: View {
    var body: some View {
        Waavform(audio: "Slapbox",
                 type: "mp3",
                 category: .playback,
                 hideTransport: false,
                 playhead: .red
        )
    }
}

```


