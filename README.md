# SwiftUI Waavform

Waveform based audio player, for SwiftUI

<img src=https://raw.githubusercontent.com/nbrandes/Waavform/main/Docs/Media/slidegallery.gif width="100%" align="right" />

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

Initialize `Waavform` with an array of views

```swift
Waavform(audio: "TheMoon", type: "mp3")
```

## Parameters

`Waavform` can be initialized with the following parameters

Required:
`audio: String` - name of the audio file
`type: String` - extension of the audio file

Optional: \
`category: AVAudioSession.Category` - (Default .playback) - category used for the AVAudioSession \
`hideTransport: Bool` - (Default false) - show or hide the playback controls \
                                    
Colors
`cursor: Color` - (Default .blue) - color used for the selection cursor \
`playhead: Color` - (Default .red) - color used for the playhead \
`progress: Color` - (Default darkGray) - color used for waavform progress \
`backing: Color` - (Default lightGray) - color used for waavform background \
 `timeText: Color` - (Default .white) - color used for current and duration time \
`timeBg: Color` - (Default .black) - color used for current and duration time background \
`control: Color`- (Default .gray) - color used for transport buttons
                                    
                                    
                                    
```swift
Waavform(views, height: 400, color: .red, scroll: true)
```

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


