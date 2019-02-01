# Episodes
Episodes downloads the latest episodes of your favorite TV shows as they air and adds them to your iTunes library and iOS devices.  Even if you don't use iTunes, the final product is an m4v file which can be played using most hardware and software playback solutions, including VLC.  Episodes is a Mac app with a simple user interface that allows you to "subscribe" to your favorite shows, either by choosing from a drop-down list of currently airing TV shows, or by entering the show's name manually.

### Features
#### Downloads torrents behind the scenes
Episodes uses a built-in CLI torrent downloader, so you don't need to have a torrent client already installed for it to work.  It's so simple that anyone can use it without any prior knowledge of BitTorrent technology.

#### Re-muxes files instead of re-encoding
The vast majority of today's TV torrents are released using h.264 video and either ac3 or aac audio in an mkv container format, in accordance with the scene rules.  Because iTunes supports h.264, ac3, and aac, no transcoding is necessary, so Episodes just re-muxes the raw streams into an iTunes-compatible m4v file, which it then automatically syncs to your devices, including iPhones, iPads, and AppleTVs.

#### Automatically fetches lots of metadata
After an episode finishes downloading, Episodes fetches metadata for it, including episode title, airdate, description, season & episode numbers, and artwork in a square format, perfectly suited for iTunes.  It also marks it as a TV show so iTunes categorizes it properly.

#### Looks for higher-quality versions of already-downloaded episodes
By default, Episodes searches online for the highest-quality file it can find for each episode, in terms of both video and audio.  If it can only find a low quality version at first (say 480p with stereo audio), it will download that one but continue looking for higher-quality versions of any episode that has not yet been deleted from your iTunes library (this feature can be disabled if the user is concerned with saving storage space).  If Episodes finds a higher-quality version (say 720p with Dolby Digital 5.1 audio), it will download it and replace the original with it in iTunes.  If the original, lower-quality episode has already been partially watced, Episodes will transfer the bookmark to the higher-quality version so you can resume watching the higher-quality version right where you left off in the original.

I've been working on this app as a hobby since 2007 and I'm constantly making improvements to it.  Check the "issues" section of this repository to see the fixes and features I have planned for the future, and let me know what you'd like to see.  Happy viewing!! 

I have included the executable .app file with each release so you don't need to install from source unless you want to.
