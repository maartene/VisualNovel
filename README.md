# VisualNovel
Simple SwiftUI based Visual Novel engine (using Ink)

## Features
* Interpret an Ink file and run it as a Visual Novel;
* Control graphics and audio using tags in Ink;
* Multiplatform project: can run on tvOS, macOS and iOS.

## Where to put assets
* Platform independant assets should be placed in the `VN Shared` group;
* Put your Ink json file in `Data`. Make sure to use drag and drop to Xcode to add it to the project and thus the bundle. Set the Ink filename (without `.json`) in `VN Shared/Constants.swift` using the `INK_FILE_NAME` constant;
* Put sprites and backgrounds in Assets.xassets;
* Put sound files in subsequent subfolders in `Audio`. Make sure to use drag and drop to Xcode to add it to the project and thus the bundle.

## Writing Ink for the engine
* You can take any ink story and it will just run;
* To make it an actual Visual Novel, use tags:
    * `# bg: image` - Change the background image to 'image';
    * `# portraitLeft: sprite` - Show a sprite named 'sprite' on the left part of the screen;
    * `# portraitRight: sprite` - Similar on the right part of the screen;
    * `# bgMusic: some.m4a` - Play some.m4a as background music (loops);
    * `# foley: another.m4a` - Play background sound effects to add atmosphere. Think like the calm rustling of leafs in the woords (loops);
    * `# sfx: bigExplosion.m4a` - Play a sound effect (one shot).
* Also, for Ink lines such as:
    `Anna: What were you thinking` - will be interpreted with Anna as the 'speaker'.

## Missing features:
* removing sprites/backgrounds from screen (for now you can only change them);
* stopping music/audio playback (for looping sounds, they can only be replaced);
* save/loading of state.

## Known issues
* I'm currently experiencing a bug with my Xcode that prevents me from running any SwiftUI application on macOS. Probably because I'm using the beta versions of Xcode and Big Sur. filed a bug with Apple: FB8805106;
* This project requires iOS14, tvOS14 and macOS 11 (Big Sur).

## Licensed components
* This project uses the [Ink language](https://www.inklestudios.com/ink) by inkle Ltd. and [InkJS runtime](https://github.com/y-lohse/inkjs) by Yannick Lohse. Both licensed under the MIT license.