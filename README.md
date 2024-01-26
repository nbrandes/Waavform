# Waavform

A simple waveform based audio player, for SwiftUI.

<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/waavform_linear.png />

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

## Example

```swift
import SwiftUI
import Waavform

struct ContentView: View {
    var body: some View {
        VStack {
            Waavform(audio: "TheMoon", type: "mp3", progress: .blue, playhead: .cyan, viewOnLoad: .scroll)
            
            Waavform(audio: "BodyHigh", type: "mp3", progress: .orange, playhead: .cyan, viewOnLoad: .linear)
            
            Waavform(audio: "Bluegoo", type: "mp3", progress: .red, playhead: .cyan)
        }
    }
}

#Preview {
    ContentView()
}

```
