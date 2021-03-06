--
--  AppDelegate.applescript
--  Episodes
--
--  Copyright � 2007-2020 Ryan Keefe.  Some rights reserved.

----REWRITE, WITH EACH INDEPENDENT PIECE BROKEN UP--EVERY ACTION, BIT OF LOGIC, ETC SHOULD BE ITS OWN SUBROUTINE--THEN STRING BACK TOGETHER.  PERFORMSELECTOR?

script AppDelegate
	property parent : class "NSObject"
	-- IBOutlets
	property thePanel : missing value
	property listOfShows : missing value
	property seasonField : missing value
	property episodeField : missing value
	property showComboField : missing value
	property beginWith : missing value
	property statusLabel : missing value
	property progressBar : missing value
	property NSTimer : class "NSTimer"
	global resourceFolder
	global listFile
    global blackFile
    global open_target_file_2
	global transmission1
    global transmission2
	global atomicParsley
	global theffmpeg
	global theMediaInfo
	global downloadingFolder
	global downloadingFolder_folder
	global downloadingCompleteFolder
	global downloads
	global processingFolder
	global processing
	global showArtFolder
	global artfolder
	global errorQueue
	global currentlyAiring
	global myshow3
	global epcodefinal
	global vid_comment
    global killedTransmission
    global secondKill
	--property showTable : missing value
	--property qualitySelect : missing value
	--property theFirstRun : 0
	-- IBActions
	on applicationWillFinishLaunching:aNotification
		tell application "Finder"
			set appLocation to (path to current application) as string
			set resourceFolder to appLocation & "Contents:Resources:" as string
			set downloadingFolder0 to appLocation & "Contents:Resources:Downloading:" as alias
			set downloadingFolder to POSIX path of downloadingFolder0 as text
			set downloadingFolder_folder to folder downloadingFolder0
			set downloadingCompleteFolder0 to appLocation & "Contents:Resources:DownloadingComplete:" as alias
			set downloadingCompleteFolder to POSIX path of downloadingCompleteFolder0 as text
			set downloads to folder downloadingCompleteFolder0
			set showArtFolder0 to appLocation & "Contents:Resources:showart:" as alias
			set showArtFolder to POSIX path of showArtFolder0 as text
			set artfolder to folder showArtFolder0
			set processingFolder0 to appLocation & "Contents:Resources:Processing:" as alias
			set processingFolder to POSIX path of processingFolder0 as text
			set processing to folder processingFolder0
			set errorFolder0 to appLocation & "Contents:Resources:Error:" as alias
			set errorQueue to folder errorFolder0
			set the listFile to (resourceFolder as string) & "show_list.txt" as string
            set the blackFile to (resourceFolder as string) & "blacklist.txt" as string
            set the open_target_file_2 to open for access file blackFile
			set transmission1 to POSIX path of resourceFolder & "transmission-daemon" as text
            set transmission2 to POSIX path of resourceFolder & "transmission-remote" as text
			set atomicParsley to POSIX path of resourceFolder & "AtomicParsley64" as text
			set theffmpeg to POSIX path of resourceFolder & "ffmpeg" as text
			set theMediaInfo to POSIX path of resourceFolder & "mediainfo" as text
			set the open_target_file to open for access file listFile
            set killedTransmission to "0"
            set secondKill to false
			try
				set showlist to read the open_target_file
				listOfShows's setStringValue:showlist
			end try
		end tell
        try
            do shell script "pkill transmission-daemon"
        end try
        do shell script transmission1 & " --download-dir \"" & downloadingCompleteFolder & "\" --incomplete-dir \"" & downloadingFolder & "\" > /dev/null 2>&1"
		---Currently airing Wikipedia check
		set find_id to do shell script "curl \"https://en.wikipedia.org/w/index.php?title=List_of_American_television_shows_currently_in_production&printable=yes\""
		set AppleScript's text item delimiters to "<li><i><a href=\"/wiki/"
		set wikiCount to count text items of find_id
		set wikiTokens0 to text items of find_id
		set firstRun to true
		set wikiShow3 to ""
		repeat with aa from 2 to wikiCount
			set wikiShow0 to item aa of wikiTokens0 ----this will work with every number from 2 to however many TV shows there are in the list
			set AppleScript's text item delimiters to "\" title=\""
			set wikiTokens1 to text items of wikiShow0
			set wikiShow1 to item 2 of wikiTokens1
			set AppleScript's text item delimiters to "\">"
			set wikiTokens2 to text items of wikiShow1
			set wikiShow2 to item 1 of wikiTokens2
			set AppleScript's text item delimiters to " ("
			set wikiTokens3 to text items of wikiShow2
			set wikiShow3 to item 1 of wikiTokens3
			set AppleScript's text item delimiters to "\""
			set wikiTokens4 to text items of wikiShow3
			set wikiShow4 to item 1 of wikiTokens4
			set AppleScript's text item delimiters to "&amp;"
			set wikiTokens5 to text items of wikiShow4
			set wikiCount2 to count wikiTokens5
			set firstRun2 to true
			if wikiCount2 is greater than 1 then
				repeat with wc from 1 to wikiCount2
					if firstRun2 is true then
						set wikiShow5 to item 1 of wikiTokens5
						set firstRun2 to false
					else
						set wikiShow5 to wikiShow5 & "and" & item wc of wikiTokens5
					end if
				end repeat
			else
				set wikiShow5 to wikiShow4
			end if
			set AppleScript's text item delimiters to "'"
			set wikiTokens6 to text items of wikiShow5
			set wikiCount3 to count wikiTokens6
			set firstRun3 to true
			if wikiCount3 is greater than 1 then
				repeat with wc2 from 1 to wikiCount3
					if firstRun3 is true then
						set wikiShow6 to item 1 of wikiTokens6
						set firstRun3 to false
					else
						set wikiShow6 to wikiShow6 & "" & item wc2 of wikiTokens6
					end if
				end repeat
			else
				set wikiShow6 to wikiShow5
			end if
			if firstRun is true then
				set wikiShow7 to wikiShow6
				set firstRun to false
			else
				if wikiShow7 does not contain wikiShow6 then
					set wikiShow7 to wikiShow7 & "
" & wikiShow6
				end if
			end if
		end repeat
		set AppleScript's text item delimiters to "
"
		set wikiTokens7 to text items of wikiShow7
		set list_string to (wikiTokens7 as string)
		set new_string to do shell script "echo " & quoted form of list_string & " | sort -f"
		set wikiShow to (paragraphs of new_string)
		tell showComboField
			addItemsWithObjectValues_(wikiShow)
		end tell
		---end currently airing wikipedia block
        NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"theStuckProcess:" userInfo:(missing value) repeats:false
        --NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"resumeTorrent:" userInfo:(missing value) repeats:false
	end applicationWillFinishLaunching:
	###########################################################################
	on applicationDidFinishLaunching:aNotification
		---launch housekeeping is currently at bottom of applicationWillFinishLaunching.  Move here instead if necessary
        NSTimer's scheduledTimerWithTimeInterval:8 target:me selector:"startTorrents:" userInfo:(missing value) repeats:false
        NSTimer's scheduledTimerWithTimeInterval:600 target:me selector:"startTorrents:" userInfo:(missing value) repeats:true
        NSTimer's scheduledTimerWithTimeInterval:5 target:me selector:"download:" userInfo:(missing value) repeats:false
		NSTimer's scheduledTimerWithTimeInterval:300 target:me selector:"download:" userInfo:(missing value) repeats:true
		NSTimer's scheduledTimerWithTimeInterval:5 target:me selector:"process:" userInfo:(missing value) repeats:true
        NSTimer's scheduledTimerWithTimeInterval:120 target:me selector:"theStuckProcess:" userInfo:(missing value) repeats:true
        --NSTimer's scheduledTimerWithTimeInterval:300 target:me selector:"resumeTorrent:" userInfo:(missing value) repeats:true
	end applicationDidFinishLaunching:
	###########################################################################
    on startTorrents:sender
        do shell script transmission2 & " --torrent all --start > /dev/null 2>&1"
        --the below block removes all completed torrents
        set remove1 to do shell script transmission2 & " -l"
        set AppleScript's text item delimiters to "
        "
        set torList to text items of remove1
        repeat with listInt from 1 to ((count of torList))
            if text item listInt of remove1 contains "100%" then
                set remove2 to text item listInt of remove1
                set AppleScript's text item delimiters to {"  100%", "*  100%"}
                set remove3 to (text item 1 of remove2)
                set AppleScript's text item delimiters to "
                "
                do shell script transmission2 & " -t " & remove3 & " -r > /dev/null 2>&1"
            end if
        end repeat
    end startTorrents
    ###########################################################################
    on populateEpcode:sender
        if showComboField's stringValue as string is not equal to "" then
            set the_index to beginWith's indexOfSelectedItem()
            if the_index is less than 2 then
                if the_index is greater than -1 then
                    set todayDate to short date string of (current date)
                    set AppleScript's text item delimiters to "/"
                    set dateTokes to text items of todayDate
                    set theMonth to item 1 of dateTokes
                    set theMonthInt to theMonth as integer
                    if theMonthInt is less than 10 then
                        set theMonth to "0" & theMonth
                    end if
                    set theDay to item 2 of dateTokes
                    set theDayInt to theDay as integer
                    if theDayInt is less than 10 then
                        set theDay to "0" & theDay
                    end if
                    set todayDate2 to "20" & item 3 of dateTokes & theMonth & theDay as integer
                    set theShowEntry to showComboField's stringValue() as text
                    set text item delimiters of AppleScript to " "
                    ----THE BELOW CODE IS VERY SIMILAR TO THE SECTION OF CODE IN THE "Processing" HANDLER THAT FETCHES THE TMDB ID FOR THE SHOW.  MAKE INTO SUBROUTINE, AND CALL WHERE NEEDED
                    set showEntry to text items of theShowEntry
                    set text item delimiters of AppleScript to "+"
                    set showEntry to "" & showEntry
                    set theTVURL to "https://www.themoviedb.org/search?query=" & showEntry
                    set find_id to do shell script "curl \"" & theTVURL & "\""
                    set text item delimiters of AppleScript to "<a id=\"tv_"
                    set apitokens to text items of find_id
                    set apiid to item 2 of apitokens
                    set text item delimiters of AppleScript to "\""
                    set apitokens to text items of apiid
                    set tvID to item 1 of apitokens
                    set myNewUrl to "api.themoviedb.org/3/tv/" & tvID & "?api_key=22c941722d77bc546e751ac90d4bebf6"
                    set API2 to do shell script "curl \"" & myNewUrl & "\""
                    ------END AREA OF CODE THAT IS VERY SIMILAR TO CODE IN "Processing" HANDLER
                    set AppleScript's text item delimiters to "season_number\":"
                    set apitokens2 to text items of API2
                    set countAPI to count items of apitokens2
                    set highSeason0 to item countAPI of apitokens2
                    set AppleScript's text item delimiters to "}],"
                    set apitokens3 to text items of highSeason0
                    set highSeason to item 1 of apitokens3
                    set nexthighSeason to (highSeason - 1)
                    set nexthighURL to "api.themoviedb.org/3/tv/" & tvID & "/season/" & nexthighSeason & "?api_key=22c941722d77bc546e751ac90d4bebf6"
                    set nexthighAPI to do shell script "curl \"" & myNewUrl & "\""
                    set AppleScript's text item delimiters to "\"air_date\":\""
                    set nexthighTokens to text items of nexthighAPI
                    set countnextAPI0 to count items of nexthighTokens
                    set countnextAPI to (countnextAPI0 + 2)
                    set myNewURL2 to "api.themoviedb.org/3/tv/" & tvID & "/season/" & highSeason & "?api_key=22c941722d77bc546e751ac90d4bebf6"
                    set API3 to do shell script "curl \"" & myNewURL2 & "\""
                    set apitokens4 to text items of API3
                    set countAPI2 to count items of apitokens4
                    set API6 to 0 as integer
                    set API60 to 0 as integer
                    repeat while API6 is equal to 0
                        set highAirdate0 to item countAPI2 of apitokens4
                        set AppleScript's text item delimiters to "\""
                        set apitokens5 to text items of highAirdate0
                        set highAirdate to item 1 of apitokens5
                        set AppleScript's text item delimiters to "-"
                        set airTokes to text items of highAirdate
                        set theAir to item 1 of airTokes & item 2 of airTokes & item 3 of airTokes as integer
                        if todayDate2 is greater than theAir then
                            set AppleScript's text item delimiters to "episode_number"
                            set apitokens6 to text items of highAirdate0
                            set API4 to item 2 of apitokens6
                            set AppleScript's text item delimiters to ":"
                            set apitokens7 to text items of API4
                            set API5 to item 2 of apitokens7
                            set AppleScript's text item delimiters to ","
                            set apitokens8 to text items of API5
                            set API6 to item 1 of apitokens8
                            set highSeason0 to highSeason as string
                        else
                            try
                                set nextAir to theAir ---this can be used in the GUI later to show when the next airdate will be
                                set AppleScript's text item delimiters to "episode_number"
                                set apitokens9 to text items of highAirdate0
                                set API40 to item 2 of apitokens9
                                set AppleScript's text item delimiters to ":"
                                set apitokens0 to text items of API40
                                set API50 to item 2 of apitokens0
                                set AppleScript's text item delimiters to ","
                                set apitokens00 to text items of API50
                                set API60 to item 1 of apitokens00
                            end try
                            set countAPI2 to (countAPI2 - 1) as integer
                            if countAPI2 is less than 2 then
                                set highSeason0 to nexthighSeason as string
                                set API6 to countnextAPI as string
                            end if
                        end if
                    end repeat
                    if the_index is equal to 1 then
                        if API60 is equal to 0 then
                            set API7 to API6 as integer
                            set API6 to (API7 + 1) as string
                            else
                            set API6 to API60 as string
                        end if
                        set highSeason0 to highSeason as string
                    end if
                    seasonField's setStringValue:highSeason0
                    episodeField's setStringValue:API6
                end if
            else if the_index is equal to 2 then
                seasonField's setStringValue:"1"
                episodeField's setStringValue:"1"
            else if the_index is equal to 3 then
                seasonField's setStringValue:""
                episodeField's setStringValue:""
            end if
        else
            seasonField's setStringValue:""
            episodeField's setStringValue:""
        end if
    end populateEpcode:
    ###########################################################################
    on addShow:sender
        if showComboField's stringValue as string = "" then
            display dialog "Please enter the name of the show."
        else
            set showEntry to showComboField's stringValue() as text
            set seasonEntry to seasonField's stringValue() as text
            if seasonField's stringValue as string = "" then
                display dialog "Please enter the season number."
                else
                try
                    set seasonEntryNum to seasonEntry as number
                on error
                    display dialog "Please enter a season number between 1 and 99."
                    seasonField's setStringValue:""
                end try
                if seasonEntryNum is less than 10 then
                    set seasonEntry to "0" & seasonEntry
                end if
                set episodeEntry to episodeField's stringValue() as text
                if episodeField's stringValue as string = "" then
                    display dialog "Please enter the episode number."
                    else
                    try
                        set episodeEntryNum to episodeEntry as number
                        on error
                        display dialog "Please enter an episode number between 1 and 99."
                        episodeField's setStringValue:""
                    end try
                    if episodeEntryNum is less than 10 then
                        set episodeEntry to "0" & episodeEntry
                    end if
                    set originalList to listOfShows's stringValue() as text
                    set AppleScript's text item delimiters to {"
", " ("}
                    set listToken to text items of originalList
                    set showDupe to false
                    repeat with i from 1 to count of listToken
                        if showEntry is equal to item i of listToken then set showDupe to true
                    end repeat
                    if showDupe is true then
                        display dialog showEntry & " has already been added to the list."
                    else
                        set finalEntry to showEntry & " (S" & seasonEntry & "E" & episodeEntry & ")"
                        if listOfShows's stringValue as string = "" then
                            listOfShows's setStringValue:finalEntry
                        else
                            set newList to current application's NSString's stringWithFormat_("%@%@%@", originalList, "
", finalEntry)
                            set newList2 to newList as text
                            set AppleScript's text item delimiters to "
"
                            set showtokens to text items of newList2
                            set list_sort to (showtokens as string)
                            set sort_string to do shell script "echo " & quoted form of list_sort & " | sort -f"
                            set sortedList to (paragraphs of sort_string)
                            set sortedList2 to sortedList as text
                            listOfShows's setStringValue:sortedList2
                        end if
                        NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"writeList:" userInfo:(missing value) repeats:false
                        delay 0.01
                    end if
                    showComboField's setStringValue:""
                    seasonField's setStringValue:""
                    episodeField's setStringValue:""
                end if
            end if
        end if
    end addShow:
    ###########################################################################
    on writeList:sender
        set newText to listOfShows's stringValue() as text
        tell application "Finder"
            set the listFile2 to the listFile as text
            set the open_master_file to open for access file listFile2 with write permission
            set eof of the open_master_file to 0
            write newText to the open_master_file
            close access the open_master_file
        end tell
    end writeList:
    ###########################################################################
    on download:sender --looks at list of shows in GUI as well as iTunes library to determine which TV episodes need to be fetched, then passes this information on to the grabTorrent: subroutine
        
        set showlist to listOfShows's stringValue() as text
        if (count of (text items of showlist)) is greater than 0 then
            repeat with c from 1 to (count of (paragraphs of showlist))
                set AppleScript's text item delimiters to {" (S0", " (S1", " (S2", " (S3", " (S4", " (S5", " (S6", " (S7", " (S8", " (S9"}
                set showname to text item 1 of (item c of (paragraphs of showlist))
                set AppleScript's text item delimiters to {showname & " (S", "E", ")"}
                set currentdata to ((text item 2 of (item c of (paragraphs of showlist))) & (text item 3 of (item c of (paragraphs of showlist))) as integer) + 90000
                ----STATBAR----
                set statbar to current application's NSString's stringWithFormat_("%@%@", "Checking sources for: ", showname)
                set incrementJump to (100 / ((count of (paragraphs of showlist)) + 1))
                if c is greater than 1 then
                    (progressBar's incrementBy:incrementJump)
                end if
                (statusLabel's setStringValue:statbar)
                ----STATBAR----
                delay 0.01
                set text item delimiters of AppleScript to " "
                set urlshow to text items of showname
                set text item delimiters of AppleScript to "+"
                set urlshow to "" & urlshow
                set text item delimiters of AppleScript to " "
                set showname2 to text items of showname
                set text item delimiters of AppleScript to "."
                set showname2 to "" & showname2 & "."
                ---check iTunes block begins here, double check that it works now that it's "TV"
                tell application "TV"
                    if (count of (items of (every track of playlist "TV Shows" whose show contains showname))) is greater than 0 then
                        repeat with f from 1 to (count of (items of (every track of playlist "TV Shows" whose show contains showname)))
                            ----PROGBAR------
                            (progressBar's incrementBy:(incrementJump / 2) / (count of (items of (every track of playlist "TV Shows" whose show contains showname))))
                            ----PROGBAR------
                            set iTunesEpcode to episode ID of item f of (every track of playlist "TV Shows" whose show contains showname)
                            set {vidQualFirst, audQualFirst} to {"0" as integer, "2" as integer}
                            repeat with i from 1 to 4
                                if (comment of item f of (every track of playlist "TV Shows" whose show contains showname)) contains item i of {"SDTV", "720p", "1080p", "4K"} then set vidQualFirst to (i - 1) as integer --this is so the video qualities correspond to integers 0, 1, 2, and 3 instead of 1, 2, 3, and 4
                            end repeat
                            repeat with i from 1 to 6
                                if (comment of item f of (every track of playlist "TV Shows" whose show contains showname)) contains item i of {"Mono", "Stereo", "3ch", "4ch", "5ch", "DD5.1"} then set audQualFirst to i as integer
                            end repeat
                            if vidQualFirst is less than 1 then --###720p LINE###-- --this is where user can set it to a different "max quality" setting
                                tell application "Finder" to set already_downloading to (every item of downloadingFolder_folder whose name contains showname2 & iTunesEpcode)
                                if count of already_downloading is 0 then
                                    set rss_items100 to do shell script "curl \"https://zooqle.com/search?q=%22" & urlshow & "%22+" & iTunesEpcode & "+x264+category%3ATV&fmt=rss\"" as text
                                    if (count of paragraphs of rss_items100) is greater than 18 then
                                        (NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"grabTorrent:" userInfo:{iTunesEpcode, rss_items100, vidQualFirst, showname, showname2} repeats:false)
                                        delay 0.01
                                    end if
                                end if
                            end if
                        end repeat
                    end if
                end tell
                ---check iTunes block ends here, check showList block begins here
                set notFound to 0
                set advanceSeason to 0
                set hasAdvanced to false
                repeat
                    set vidQualFirst to -1 as integer --there is no original vidQual, since we are not replacing something in itunes, so we set it to -1, so anything found will be downloaded
                    set urlepcode to "S" & text 2 thru 3 of (currentdata as text) & "E" & text 4 thru 5 of (currentdata as text)
                    tell application "Finder" to set already_downloading to (every item of downloadingFolder_folder whose name contains showname2 & urlepcode)
                    if count of already_downloading is 0 then
                        set rss_items200 to do shell script "curl \"https://zooqle.com/search?q=%22" & urlshow & "%22+" & urlepcode & "+x264+category%3ATV&fmt=rss\"" as text
                        if (count of paragraphs of rss_items200) is greater than 18 then
                            (NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"grabTorrent:" userInfo:{urlepcode, rss_items200, vidQualFirst, showname, showname2} repeats:false)
                            delay 0.01
                            set notFound to 0
                            set advanceSeason to 0
                            set hasAdvanced to false
                        else
                            set notFound to notFound + 1
                            if notFound is greater than or equal to 4 then
                                if advanceSeason is less than 2 then
                                    set notFound to 2
                                    set advanceSeason to advanceSeason + 1
                                end if
                            end if
                            if advanceSeason is 2 then
                                exit repeat
                            end if
                        end if
                    end if
                    if advanceSeason is 0 then
                        set currentdata to currentdata + 1
                    else if advanceSeason is 1 then
                        if hasAdvanced is false then
                            set currentDataText to currentdata as text
                            set currentDataInt to ((text 4 thru 5 of currentDataText) as integer)
                            set currentDataSubtract to (101 - currentDataInt) as integer
                            set currentdata to currentdata + currentDataSubtract as integer
                            set hasAdvanced to true
                        else if hasAdvanced is true then
                            set currentdata to currentdata + 1
                        end if
                    end if
                end repeat
            end repeat
            ----STATBAR3----
            set statbar3 to current application's NSString's stringWithFormat_("%@", "Idle") --shouldn't always be idle, leave "downloading" statuses up until the episode is added to itunes, then say adding, then idle.
            progressBar's incrementBy:incrementJump
            statusLabel's setStringValue:statbar3
            delay 0.01
            progressBar's incrementBy:-100
            ----STATBAR3----
        end if
    end download:
    ###########################################################################
    on grabTorrent:sender
        set theEpcode to item 1 of sender's userInfo as text
        set rss_items to item 2 of sender's userInfo as text
        set vidQualFirst to item 3 of sender's userInfo as integer
        set showname to item 4 of sender's userInfo as text
        set showname2 to item 5 of sender's userInfo as text
        set blacklistedHash to true
        repeat while blacklistedHash is true
            set blacklistedHash to false
            set bestquality to 0 as integer
            set bestfeeditem to 0 as integer
            set secondbest to 0 as integer
            set thirdbest to 0 as integer
            set fourthbest to 0 as integer
            set fifthbest to 0 as integer
            set AppleScript's text item delimiters to "<item>"
            set feedtokens to text items of rss_items
            try
                set oldBlackHash to read the open_target_file_2
                on error
                try
                    if oldBlackHash is {} then set oldBlackHash to "0000000000000000000000000000000000000000"
                on error
                    set oldBlackHash to "0000000000000000000000000000000000000000"
                end try
            end try
            repeat with i from 2 to count of feedtokens
                set currentEntry to item i of feedtokens
                set AppleScript's text item delimiters to {"<title>", "</title>"}
                set feedtorrentTitle to text item 2 of currentEntry
                set AppleScript's text item delimiters to {"<torrent:infoHash>", "</torrent:infoHash>"}
                set feedtorrentLink to text item 2 of currentEntry
                if oldBlackHash does not contain feedtorrentLink then
                    set tor_comment to "SDTV"
                    set torQual to 0 as integer
                    if feedtorrentTitle contains theEpcode
                        ###720p BLOCK###
                        if feedtorrentTitle contains "720p" then
                            set tor_comment to "720p"
                            set torQual to 1
                        end if
                        ###END 720p BLOCK###
                        set torAudQual to 2 as integer
                        ---the below (from here to end repeat) sets the torAudQual, but nothing checks the torAudQual later!  Implement something (a few lines down, when it is checking the torQual) to also check the torAudQual
                        ignoring case, hyphens, punctuation and white space
                            if feedtorrentTitle contains "AAC2.0" then
                                set torAudQual to 2 as integer
                                else if feedtorrentTitle contains "DD5.1" then
                                set torAudQual to 6 as integer
                                else if feedtorrentTitle contains "6ch" then
                                set torAudQual to 6 as integer
                                --aac often means 2.0, and if it doesn't say aac2.0 or dd5.1, it is most likely 5.1, so it should prefer 5.1 or ac3 to nothing, and prefer nothing to 2.0 or web-dl or aac, unless web-dl also says 5.1
                            end if
                        end ignoring
                        set chanList to {"Mono", "Stereo", "3ch", "4ch", "5ch", "DD5.1"}
                        repeat with j from 1 to count of chanList
                            if feedtorrentTitle contains item j of chanList then
                                set torAudQual to j as integer
                            end if
                        end repeat
                        set torSourceQual to 2 as integer
                        set sourcList to {"WEB-DL", "TV-Rip", "Blu-Ray"}
                        ignoring case, hyphens, punctuation and white space
                            if feedtorrentTitle contains "Web-Rip" then
                                set torSourceQual to 1 as integer
                            end if
                            repeat with j from 1 to count of sourcList
                                if feedtorrentTitle contains item j of sourcList then
                                    set torSourceQual to j as integer
                                end if
                            end repeat
                        end ignoring
                        ----make it so if a torrent is nuked and propered, the proper replaces the nuke
                        if torQual is greater than vidQualFirst then
                            ----also add in audio and source quality checkers here...torAudQual and torSourceQual are set just a few lines above and should be checked here!!
                            if torQual is greater than or equal to bestquality then
                                set bestquality to torQual as integer
                                try
                                    set fifthbest to fourthbest
                                end try
                                try
                                    set fourthbest to thirdbest
                                end try
                                try
                                    set thirdbest to secondbest
                                end try
                                try
                                    set secondbest to bestfeeditem
                                end try
                                set bestfeeditem to feedtorrentLink & ": " & feedtorrentTitle
                            end if
                        end if
                    end if
                end if
            end repeat
            if bestfeeditem is not 0 then
                set the_order to {bestfeeditem, secondbest, thirdbest, fourthbest, fifthbest}
                set AppleScript's text item delimiters to ": "
                repeat with tho from 1 to 5
                    set final_torrent to item tho of the_order
                    set theHash to (text item 1 of final_torrent)
                    set tor_comment to "SDTV"
                    set aud_comment to "Stereo"
                    set source_comment to "TV-Rip"
                    ###720p BLOCK###
                    if final_torrent contains "720p" then set tor_comment to "720p" as text
                    ###END 720p BLOCK###
                    ignoring case, hyphens, punctuation and white space
                        if final_torrent contains "DD5.1" then
                            set aud_comment to "DD5.1"
                        else if final_torrent contains "6ch" then
                            set aud_comment to "DD5.1"
                        end if
                    end ignoring
                    repeat with j2 from 1 to count of chanList
                        if final_torrent contains item j2 of chanList then set aud_comment to item j2 of chanList as text
                    end repeat
                    ignoring case, hyphens, punctuation and white space
                        if final_torrent contains "webdl" then
                            set source_comment to "Web-DL"
                        else if final_torrent contains "webrip" then
                            set source_comment to "Web-DL"
                        else if final_torrent contains "bdrip" then
                            set source_comment to "Blu-Ray"
                        else if final_torrent contains "bluray" then
                            set source_comment to "Blu-Ray"
                        end if
                    end ignoring
                    set final_torrent2 to "magnet:?xt=urn:btih:" & theHash
                    #try -- comments with hashtags (this line, and the block a few lines down) WILL BE ADDED BACK once it is tested this way first, and once it can be established that try/on error will actually work with shell script and the dev/null
                    do shell script transmission2 & " -a \"" & final_torrent2 & "\" > /dev/null 2>&1"
                        ----STATBAR2----
                        set statbar2 to current application's NSString's stringWithFormat_("%@%@%@%@%@%@%@", "Downloading ", showname, " ", theEpcode, " in ", tor_comment, " quality.")
                        (statusLabel's setStringValue:statbar2)
                        delay 0.01
                        ----STATBAR2----
                    --else
                    ###insert code here that checks the downloading folder after 90 seconds or so have passed to see if there is anything in there with theHash in its filename.  If there is not, or if the transmission cli throws an error (caused by the torrent not being good), then do the below
                    #on error
                    #set blacklistedHash to true
                    #tell application "Finder"
                    #set the blackFile2 to the blackFile as text
                    #set the open_master_file_2 to open for access file blackFile2 with write permission
                    #set eof of the open_master_file_2 to 0
                    #write theHash & return & oldBlackHash to open_master_file_2
                    #set oldBlackHash to (theHash & return & oldBlackHash)
                    #close access the open_master_file_2
                    #end tell
                    #end try
                    exit repeat --make sure it also exits and moves on to the next episode number if it can't download anything from the_order
                end repeat            
            end if
        end repeat
    delay 0.01
	end grabTorrent:
    ###########################################################################
   -- on resumeTorrent:sender  --this subroutine starts re-downloading any episode in the downloading directory that has not been modified in the past 10 minutes.
     --   tell application "Finder"
       --     ignoring case, hyphens, punctuation and white space
         --       repeat with z from 1 to (count of (every item of downloadingFolder_folder))
                    --set ariaMatchCount to count (every item of downloadingFolder_folder whose name contains downloadingMatchName)
                    --  if (creation date of (item 1 of downloadingFolder_folder whose name contains downloadingMatchName)) � ((current date) - 10 * minutes) then
                        -----add code for adding this hash to the blacklist and trying another one for that same episode!
                            -- set redownloadHash to "magnet:?xt=urn:btih:" & downloadingHash
                            --do shell script aria & " --seed-time=0 --enable-dht=true --follow-torrent=mem --on-bt-download-complete=exit -d " & downloadingfolder & " " & quoted form of redownloadHash & " > /dev/null 2>&1 &"
                --    end if
            --   end repeat
         --   end ignoring
     --   end tell
   -- end resumeTorrent:
    ###########################################################################
	on process:sender
        tell application "Finder"
			----From here to the next comment, the script checks downloadcomplete folder for video files, then deletes everything it doesn't need
			repeat while (count of folders in downloads) is greater than 0
				set downloads2_delete to name of (folder 1 of downloads)
				move {(every item of (folder 1 of downloads) whose name ends with ".mkv"), (every item of (folder 1 of downloads) whose name ends with ".mp4"), (every item of (folder 1 of downloads) whose name ends with ".m4v")} to downloads with replacing
				try
					do shell script "rm -r " & downloadingCompleteFolder & quoted form of downloads2_delete
				end try
			end repeat
			--The below renames the file to the proper naming format
			if exists item 2 of downloads then
				if not exists item 2 of processing then
					move item 1 of (every item of downloads whose name does not contain "dummyfile") to processing
                    set the_file to item 1 of (every item of processing whose name does not contain "dummyfile")
					---the 2 lines below set the variable to just the filename (everything after the last colon), as opposed to the whole path
					set AppleScript's text item delimiters to ":"
					set allfilenames to last text item of (the_file as text)
					tell current application
						----the 4 lines below change any dashes in the filename to dots
						set text item delimiters of AppleScript to {" - ", " "}
						set someText2 to text items of allfilenames
						set text item delimiters of AppleScript to "."
						set someText2 to "" & someText2
						set tokens to text items of someText2
						set extension1 to "." & last text item of tokens ----the file type, which can be used later when determining which shell script to use
						set capitalizedfinal to {}
						set nameLength to ((count tokens) - 1) --the minus 1 gets rid of the extension so it doesn't capitalize it
						repeat with zz from 1 to nameLength
							set myWord to item zz of tokens
							--if the first letter is not capitalized, make it upper case
							set firstLetter to character 1 of myWord
							considering case
								if firstLetter is not in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" then set firstLetter to do shell script "echo " & firstLetter & " | tr '[a-z]' '[A-Z]'"
								--make the rest of the letters lower case
								if length of myWord > 1 then
									set lowerletters to text 2 thru (length of myWord) of myWord
									set lowerletters to do shell script "echo " & lowerletters & " | tr '[A-Z]' '[a-z]'"
								else
									set lowerletters to ""
								end if
							end considering
							if zz is equal to 1 then
								try
									set capitalizedfinal to firstLetter & lowerletters
								end try
							else
								try
									set capitalizedfinal to capitalizedfinal & "." & firstLetter & lowerletters
								end try
							end if
						end repeat
					end tell
					set AppleScript's text item delimiters to {".S0", ".S1", ".S2", ".S3", ".S4", ".S5", ".S6", ".S7", ".S8", ".S9"}
					----below checks the video quality.  0 = 480p or lower, 1 = 720p, 2 = 1080p, 3 = 4K
					set vidQual to "0" as integer ---if there is no indication of the quality, we assume that it is 480p or below.  this value will be changed by the "if" statements below if the title does contain the quality or mediainfo discovers it
					set vid_comment to "SDTV"
					set vidHeight to do shell script theMediaInfo & " \"--Inform=Video;%Height%\" " & processingFolder & "*.{mkv,mp4,m4v}"
					set vidheight2 to vidHeight as integer
					if vidheight2 is less than 535 then
						set vidQual to "0" as integer
						set vid_comment to "SDTV"
					else if vidheight2 is less than 803 then
						if vidheight2 is greater than or equal to 535 then
							set vidQual to "1" as integer
							set vid_comment to "720p"
						end if
					else if vidheight2 is less than 1606 then
						if vidheight2 is greater than or equal to 803 then
							set vidQual to "2" as integer
							set vid_comment to "1080p"
						end if
					else if vidheight2 is greater than or equal to 1606 then
						set vidQual to "3" as integer
						set vid_comment to "4K"
					end if
					----The below checks to see how many audio channels are in the MKV file.  This is used to determine, in a case where the same episode already has been added to iTunes, if the incoming episode should replace it because it has more audio channels.
					set aud_comment to "Stereo" --this line and the line below are just in case there's a problem retrieving the number of audio channels in the file, we assume it is stereo until the processes below tell us otherwise
                    set channels2 to "2" as integer
					set channels to do shell script theMediaInfo & " \"--Inform=Audio;%Channels%\" " & processingFolder & "*.{mkv,mp4,m4v}"
					set stream1 to 0 as integer
					set stream2 to 0 as integer
					set stream3 to 0 as integer
					-----the below checks EACH audio stream to see how many channels it has
					try
						set stream1 to text 1 of channels as integer
					end try
					try
						set stream2 to text 2 of channels as integer
					end try
					try
						set stream3 to text 3 of channels as integer
					end try
					------this part sees which audio stream has the greatest number of channels, and that is the audio stream that matters because if a file has stereo and 5.1 audio, the 5.1 audio is what will be extracted and used.
					if stream1 is greater than or equal to stream2 then
						if stream1 is greater than or equal to stream3 then
							set channels2 to stream1
						end if
					else if stream2 is greater than or equal to stream1 then
						if stream2 is greater than or equal to stream3 then
							set channels2 to stream2
						end if
					else if stream3 is greater than or equal to stream1 then
						if stream3 is greater than or equal to stream2 then
							set channels2 to stream3
						end if
					end if
					set channels2List to {"Mono", "Stereo", "3ch", "4ch", "5ch", "DD5.1"}
                    repeat with i from 1 to count of channels2List
						if channels2 is equal to i then
							set aud_comment to item i of channels2List as text
						end if
					end repeat
					set sourceQual to "2" as integer ---if there is no indication of the source in the title, we assume that it is a TV rip.  TV rip = 2, BDrip = 3, WEB-DL = 1
					set source_comment to "TV-Rip"
					---for the below to work, when it renames the file in the folder, it can't clip off everything after the epcode!
                    ignoring case, hyphens, punctuation and white space
						if text of capitalizedfinal contains "webdl" then
							set sourceQual to "1" as integer
							set source_comment to "Web-DL"
						else if text of capitalizedfinal contains "webrip" then
							set sourceQual to "1" as integer
							set source_comment to "Web-DL"
						else if text of capitalizedfinal contains "bdrip" then
							set sourceQual to "3" as integer
							set source_comment to "Blu-Ray"
						else if text of capitalizedfinal contains "bluray" then
							set sourceQual to "3" as integer
							set source_comment to "Blu-Ray"
						end if
					end ignoring
					set final_comment to vid_comment & " " & aud_comment & " " & source_comment
					set totaltokens2 to count text items of capitalizedfinal
					if totaltokens2 is equal to 1 then -----if the show DOES NOT use the standard SxxExx naming format
						set AppleScript's text item delimiters to {".720p.", ".1080p.", "4K"}
						set totaltokens3 to count text items of capitalizedfinal
						if totaltokens3 is equal to 1 then
							set AppleScript's text item delimiters to {".HDTV.", ".hdtv."}
						end if
					end if
					set tokens to text items of capitalizedfinal
					set myshow to item 1 of tokens -----The name of the show, formatted as "30.Rock"
					if totaltokens2 is greater than 1 then -----if the show uses the standard SxxExx naming format
						set AppleScript's text item delimiters to myshow & "."
						set tokens to text items of capitalizedfinal
						set preepcode to item 2 of tokens
						set AppleScript's text item delimiters to "."
						set tokens to text items of preepcode
						set epcode to item 1 of tokens
						set epcodefinal to "S" & text 2 thru 3 of epcode & "E" & text 5 thru 6 of epcode ----The EpisodeID, formatted as "S04E09"
					end if
					set fileNameNoExt to myshow & "." & vid_comment & "." & aud_comment & "." & source_comment & extension1
					if totaltokens2 is greater than 1 then -----if the show uses the standard SxxExx naming format
						set fileNameNoExt to myshow & "." & epcodefinal & "." & vid_comment & "." & aud_comment & "." & source_comment & extension1
					end if
					set name of the_file to fileNameNoExt
					tell current application
						---if show name is weird, reset it here!  THIS SHOULD ONLY BE A TEMPORARY FIX, FIND A BETTER WAY TO DO THIS THAN MANUALLY ENTERING IT HERE...
						----The Office
						set myshow3 to text of myshow
						if myshow3 contains "The.Office.US" then
							set myshow to "The.Office"
							----The Newsroom
						else if myshow3 contains "The.Newsroom.2012" then
							set myshow to "The.Newsroom"
                        else if myshow3 contains "Search.Party.2016" then
                            set myshow to "Search.Party"
                            else if myshow3 contains "Search.Party.2016" then
                            set myshow to "Search.Party"
						end if
						----the 4 lines below change any dots in the filename to spaces
						set text item delimiters of AppleScript to "."
						set showname2 to text items of myshow
						set text item delimiters of AppleScript to " "
						set showname2 to "" & showname2
						if totaltokens2 is greater than 1 then -----if the show uses the standard SxxExx naming format
							----the 4 lines below change any dots in the filename to plus signs (for the URL later)
							set text item delimiters of AppleScript to "."
							set myshow2 to text items of myshow
							set text item delimiters of AppleScript to "+"
							set myshow2 to "" & myshow2
							set url1 to "https://www.themoviedb.org/search?query=" & myshow2
							----% xferd error (6) MAY occur on following line.
							try
								set find_id to do shell script "curl \"" & url1 & "\""
							on error
								tell application "Finder" to move the_file to errorQueue
							end try
							if exists item 2 of processing
                                set text item delimiters of AppleScript to "<a id=\"tv_"
                                set tokens to text items of find_id
                                set id0 to item 2 of tokens
                                set text item delimiters of AppleScript to "\""
                                set tokens to text items of id0
                                set tvshowID to item 1 of tokens
                                set mySeason to text 2 through 3 of epcodefinal as number
                                set mySeason2 to mySeason as text
                                set myEpisode to text 5 through 6 of epcodefinal as number
                                set myEpisode2 to myEpisode as text
                                set mySeason2 to text 2 through 3 of epcodefinal
                                set myEpisode2 to text 5 through 6 of epcodefinal
                                set firstmyurl to "api.themoviedb.org/3/tv/" & tvshowID & "?api_key=22c941722d77bc546e751ac90d4bebf6"
                                try
                                    set firstin2 to do shell script "curl \"" & firstmyurl & "\""
                                    on error
                                    tell application "Finder" to move the_file to errorQueue
                                end try
                                if exists item 2 of processing
                                set AppleScript's text item delimiters to "\"original_name\":\""
                                set correctName0 to text item 2 of firstin2
                                set AppleScript's text item delimiters to "\",\""
                                set correctName1 to text item 1 of correctName0
                                set text item delimiters of AppleScript to " "
                                set correctName2 to text items of correctName1
                                set text item delimiters of AppleScript to "+"
                                set correctName2 to "" & correctName2
                                set myurl to "api.themoviedb.org/3/tv/" & tvshowID & "/season/" & mySeason2 & "/episode/" & myEpisode2 & "?api_key=22c941722d77bc546e751ac90d4bebf6"
                                ----% xferd error (6) occurs on following line.
                                try
                                    set in2 to do shell script "curl \"" & myurl & "\""
                                    on error
                                    tell application "Finder" to move the_file to errorQueue
                                end try
                                if exists item 2 of processing
                                    set showdescrip to "No description available."
                                    set myname to "Season " & mySeason & ", Episode " & myEpisode
                                    set AppleScript's text item delimiters to "\",\"overview\":\""
                                    set tokens to text items of in2
                                    set myname1 to item 1 of tokens
                                    if myname1 does not contain "The resource you requested could not be found" then
                                        set descrip1 to item 2 of tokens
                                        set AppleScript's text item delimiters to "\""
                                        set tokens to text items of myname1
                                        set myname to last item of tokens as text ---episode name
                                        set AppleScript's text item delimiters to "\",\"id"
                                        set tokens to text items of descrip1
                                        set descrip2 to item 1 of tokens ---description
                                        set text item delimiters of AppleScript to {"'", "\"", "\\"}
                                        set descrip2 to text items of descrip2
                                        set text item delimiters of AppleScript to ""
                                        set descrip2 to "" & descrip2
                                        set text item delimiters of AppleScript to "<br>
        "
                                        set descrip2 to text items of descrip2
                                        set text item delimiters of AppleScript to "  "
                                        set descrip2 to "" & descrip2
                                        try
                                            if descrip2 is not "" then set showdescrip to descrip2 as text
                                        end try
                                        set AppleScript's text item delimiters to "\"air_date\":\""
                                        set tokens to text items of in2
                                        set myair to item 2 of tokens
                                        set AppleScript's text item delimiters to "\""
                                        set tokens to text items of myair
                                        set myair2 to item 1 of tokens as text ---airdate
                                    end if
                                    -----FETCH ARTWORK
                                    tell application "Finder"
                                        set oldArt to (every item of artfolder whose creation date � ((current date) - 4 * weeks))
                                        repeat with oa from 1 to count of oldArt
                                            set deleteArt to name of item oa of oldArt
                                            if deleteArt does not contain "no_art" then
                                                do shell script "rm " & showArtFolder & quoted form of deleteArt & " > /dev/null 2>&1"
                                            end if
                                        end repeat
                                        set artfiles to (every item of artfolder whose name contains myshow2)
                                        set artcount to count artfiles
                                        try
                                            set artname to name of item 1 of artfiles
                                        end try
                                    end tell
                                    if artcount is greater than 0 then
                                        set final_final_artwork to showArtFolder & artname as string
                                    else
                                        set arturl to "https://squaredtvart.tumblr.com/search/" & correctName2
                                        try
                                            set find_artlink to do shell script "curl \"" & arturl & "\""
                                            set AppleScript's text item delimiters to "_250.jpg"
                                            set arttokens to text items of find_artlink
                                            set the_artlink00 to item 1 of arttokens
                                            set AppleScript's text item delimiters to "https://"
                                            set arttokens2 to text items of the_artlink00
                                            set the_artlink to "https://" & (last item of arttokens2) & "_1280.jpg"
                                            set the_artlink2 to "https://" & (last item of arttokens2) & "_500.jpg"
                                            
                                        end try
                                        try
                                            try
                                                do shell script "curl " & the_artlink & " -o " & "\"" & showArtFolder & myshow2 & ".jpg\""
                                            on error
                                                try
                                                    do shell script "curl " & the_artlink2 & " -o " & "\"" & showArtFolder & myshow2 & ".jpg\""
                                                end try
                                            end try
                                            set final_final_artwork to showArtFolder & myshow2 & ".jpg"
                                        on error
                                            set final_final_artwork to showArtFolder & "no_art.jpg" as string
                                        end try
                                    end if --(artcount is greater than 0)
                                end if
                            end if
                        end if
                    else
                        set myname to showname2
                        set final_final_artwork to showArtFolder & "no_art.jpg" as string
                    end if --(totaltokens2 is greater than 1)
                    set text item delimiters of AppleScript to {":", "'"}
                    set showname2 to text items of showname2 ---showname2 = name of the show
                    set myname to text items of myname ---myname = name of the episode
                    set text item delimiters of AppleScript to ""
                    set showname2 to "" & showname2
                    set myname to "" & myname
                    set EPids to "N/A"
                    set shouldcheckiTunes to false
                end tell
					tell application "TV"
						set existsShows to every track of playlist "TV Shows" whose name contains myname --episode title
						set countfiles to count items of existsShows
						set replaceShow to {}
						if countfiles is greater than 0 then
							repeat with i from 1 to countfiles
								if show of item i of existsShows contains showname2 then
									set replaceShow to item i of existsShows
								end if
							end repeat
							if replaceShow is not {} then
								set EPids to comment of replaceShow
								set playbackpos to bookmark of replaceShow
								set shouldcheckiTunes to true
							end if
						end if
					end tell
					set replacefirst to true
					if shouldcheckiTunes is true then
						tell current application
							set vidQualFirst to "-1" as integer
							set audQualFirst to "-1" as integer
							set sourceQualFirst to "-1" as integer
							if EPids is not "N/A" then
								set vidQualFirst to "0" as integer
								set audQualFirst to "2" as integer
								set sourceQualFirst to "2" as integer
							end if
							set videoList to {"SDTV", "720p", "1080p", "4K"}
							repeat with i from 1 to count of videoList
								if EPids contains item i of videoList then
									set vidQualFirst to (i - 1) as integer
								end if
							end repeat
							set channelList to {"Mono", "Stereo", "3ch", "4ch", "5ch", "DD5.1"}
							repeat with i from 1 to count of channelList
								if EPids contains item i of channelList then
									set audQualFirst to i as integer
								end if
							end repeat
							set sourceList to {"WEB-DL", "TV-Rip", "Blu-Ray"}
							repeat with i from 1 to count of sourceList
								if EPids contains item i of sourceList then
									set sourceQualFirst to i as integer
								end if
							end repeat
							set replacefirst to false
							if vidQual is greater than vidQualFirst then
								set replacefirst to true
							end if
							if vidQualFirst is 1 then ---iTunes 720p
								if audQualFirst is greater than channels2 then ---itunes 5.1, incoming stereo
									if vidQual is not 3 then ----incoming is not 4K
										set replacefirst to false
									end if
								end if
							end if
							if vidQual is 1 then --incoming 720p
								if channels2 is greater than audQualFirst then ---incoming 5.1, iTunes stereo
									if vidQualFirst is not 3 then --itunes is not 4K
										set replacefirst to true
									end if
								end if
							end if
							if vidQual is equal to vidQualFirst then ---if incoming and itunes are same video resolution
								if channels2 is greater than audQualFirst then ---incoming 5.1, itunes stereo
									set replacefirst to true
								else if channels2 is equal to audQualFirst then
									if sourceQual is greater than sourceQualFirst then
										set replacefirst to true
									end if
								end if
							end if
						end tell
					end if
					set continue_adding to true
					if replacefirst is false then set continue_adding to false
					if continue_adding is false then
						do shell script "rm " & processingFolder & "*.[^keep]*"
                        NSTimer's scheduledTimerWithTimeInterval:0 |target|:me selector:"updateEpcode:" userInfo:{showname2, mySeason2, myEpisode2} repeats:false
                        delay 0.01
					else if continue_adding is true then
						if extension1 is ".mkv" then
                            tell current application to set {langList, langChannels} to {do shell script theMediaInfo & " \"--Inform=General;%Audio_Language_List%\" " & processingFolder & "*.{mkv,mp4,m4v}", do shell script theMediaInfo & " \"--Inform=Audio;%Channels%\" " & processingFolder & "*.{mkv,mp4,m4v}"}
                            set allEnglish to true
                            set englishTrack to ""
                            set AppleScript's text item delimiters to "/"
                            set langTokens to text items of langList
                            repeat with i from 1 to count of langTokens
                                if item i of langTokens does not contain "English" then set allEnglish to false
                            end repeat
                            if allEnglish is true
                                try
                                    tell current application to	do shell script theffmpeg & " -i " & processingFolder & "*.mkv -c:v copy -c:a copy " & processingFolder & fileNameNoExt & ".m4v && rm " & processingFolder & "*.mkv"
                                on error
                                    try
                                        tell current application to	do shell script theffmpeg & " -i " & processingFolder & "*.mkv -y -c:v copy -c:a ac3 " & processingFolder & fileNameNoExt & ".m4v && rm " & processingFolder & "*.mkv"
                                        on error
                                    ----blacklist the torrent hash, delete the file
                                    end try
                                end try
                            else --if allEnglish is false
                                repeat with i from 1 to count of langTokens
                                    if item i of langTokens contains "English" then
                                        if englishTrack is "" then
                                            set englishTrack to i as integer
                                            set langChannels0 to text i of langChannels
                                        else
                                            if text i of langChannels is greater than langChannels0 then
                                                set langChannels0 to text i of langChannels
                                                set englishTrack to i as integer
                                            end if
                                        end if
                                    end if
                                end repeat
                                set englishTrackFinal to (englishTrack - 1)
                                tell current application to do shell script theffmpeg & " -i " & processingFolder & "*.mkv -map 0:v:0 -map 0:a:" & englishTrackFinal & " -c copy " & processingFolder & fileNameNoExt & ".m4v && rm " & processingFolder & "*.mkv"
                            end if
							set the_file to every item of processing whose name ends with ".mp4"
							set the_file to every item of processing whose name ends with ".m4v"
						end if --(extension1 is mkv)
					end if --(continue_adding is false/true)
				end if --(not exists item 2 of processing)
			end if ---(not exists item 2 of downloads)

            try
				set totalprocessing to count files in processing
				if totalprocessing is greater than 3 then
					do shell script "rm " & processingFolder & "*.[^keep]*"
				end if
				if name of item 1 of processing contains "dummyfile" then
					set the_file to item 2 of processing
				else
					set the_file to item 1 of processing
				end if
				set origin to name of the_file
				set rmfile to the_file as alias
				set rm2 to POSIX path of rmfile as text
				if origin ends with ".mp4" then set goOn to true
				if origin ends with ".m4v" then set goOn to true
				if goOn is true then
					if totaltokens2 is greater than 1 then --if the show uses the standard SxxExx naming format
						tell current application
							if myname1 does not contain "The resource you requested could not be found" then
								do shell script atomicParsley & " " & processingFolder & origin & " --stik 'TV Show' --TVShowName '" & showname2 & "' --TVEpisode '" & epcodefinal & "' --comment '" & final_comment & "' --TVSeasonNum '" & mySeason & "' --TVEpisodeNum '" & myEpisode & "' --album '" & showname2 & ", Season " & mySeason & "' --tracknum '" & myEpisode & "' --disk '" & mySeason & "' --artwork REMOVE_ALL --artwork " & final_final_artwork & " --year '" & myair2 & "' --title '" & myname & "' --description '" & showdescrip & "'"
							else
								do shell script atomicParsley & " " & processingFolder & origin & " --stik 'TV Show' --TVShowName '" & showname2 & "' --TVEpisode '" & epcodefinal & "' --comment '" & final_comment & "' --TVSeasonNum '" & mySeason & "' --TVEpisodeNum '" & myEpisode & "' --album '" & showname2 & ", Season " & mySeason & "' --tracknum '" & myEpisode & "' --disk '" & mySeason & "' --artwork REMOVE_ALL --artwork " & final_final_artwork & " --title '" & myname & "' --description '" & showdescrip & "'"
							end if
						end tell
					else -----if the show does not use the standard SxxExx naming format
						tell current application to do shell script atomicParsley & " " & processingFolder & origin & " --stik 'TV Show' --TVShowName '" & showname2 & "' --comment '" & final_comment & "' --artwork REMOVE_ALL --artwork " & final_final_artwork & "' --title '" & myname & "'"
					end if
					set metafiles2 to (every item of processing whose name contains "temp") as alias
					tell application "TV"
						if replaceShow is not {} then
							set itunesShow to location of replaceShow
							set i2 to POSIX path of itunesShow as text
							do shell script "rm " & quoted form of i2
							delete replaceShow
						end if
						try
							add metafiles2
						on error
                            tell application "Finder" to move the_file to errorQueue
						end try
                        tell current application
                            do shell script "rm " & processingFolder & "*.[^keep]* > /dev/null 2>&1"
                            NSTimer's scheduledTimerWithTimeInterval:0 |target|:me selector:"updateEpcode:" userInfo:{showname2, mySeason2, myEpisode2} repeats:false
                            delay 0.01
                        end tell
						try
							set existsShows to every track of playlist "TV Shows" whose name contains myname
							set countfiles to count items of existsShows
							if countfiles is greater than 0 then
								repeat with i from 1 to countfiles
									if show of item i of existsShows contains showname2 then
										set finalShow to item i of existsShows
									end if
								end repeat
								set bookmark of finalShow to (playbackpos - 5)
                            end if
						end try
					end tell
					if (count of files in processing) is greater than 1 then
						do shell script "rm " & quoted form of rm2 & " > /dev/null 2>&1"
						do shell script "rm " & processingFolder & "*-temp-*.* > /dev/null 2>&1"
					end if
				end if --(goOn is true)
			end try
			set the_file to {}
		end tell
	end process:
    ###########################################################################
    on theStuckProcess:sender --this subroutine moves/deletes any files that may have gotten stuck in the processing folder if they fail to process
        tell application "Finder"
            set secondChance to false
            set stuckProcess to (every item of processing whose name does not contain "dummyfile")
            if count of stuckProcess is greater than 0
                if modification date of item 1 of stuckProcess � ((current date) - 12 * minutes) then  --if the file in the processing folder hasn't been modified in the last 12 minutes
                    if (count of stuckProcess) is 1 then
                        set secondChance to true
                        move item 1 of stuckProcess to downloads ---moves the file that got stuck during processing back to the downloadingcomplete folder.
                        if exists item 2 of processing then do shell script "rm " & processingFolder & "*.[^keep]* > /dev/null 2>&1"
                    else if (count of stuckProcess) is 2 then
                        if modification date of item 2 of stuckProcess � ((current date) - 12 * minutes) then
                            if creation date of item 1 of stuckProcess is less than or equal to creation date of item 2 of stuckProcess
                                move (item 1 of stuckProcess) to downloads --item 1 is older than (or exactly the same age as) item 2
                                set secondChance to true
                            end if
                            try
                                if creation date of item 2 of stuckProcess is less than creation date of item 1 of stuckProcess
                                    move (item 2 of stuckProcess) to downloads ---item 2 is older than item 1
                                    set secondChance to true
                                end if
                            end try
                            if exists item 2 of processing then do shell script "rm " & processingFolder & "*.[^keep]* > /dev/null 2>&1"
                        end if
                    end if
                end if
            end if
        end tell
    end theStuckProcess:
    ###########################################################################
    on updateEpcode:sender ----updates epcode in list of shows view
            set showname2 to item 1 of sender's userInfo as text
            set mySeason2 to item 2 of sender's userInfo as text
            set myEpisode2 to item 3 of sender's userInfo as text
            set old_data0 to listOfShows's stringValue() as text
            set newDelim to showname2 & " (S"
            set AppleScript's text item delimiters to newDelim
            set epcodeTokens to text items of old_data0
            set beforeEpcode0 to item 1 of epcodeTokens
            set beforeEpcode to beforeEpcode0 & newDelim
            set old_data1 to item 2 of epcodeTokens
            set AppleScript's text item delimiters to ")"
            set epcodeTokens2 to text items of old_data1
            set old_data2 to item 1 of epcodeTokens2 ---everything between the parentheses, except for the S.  Ex: 04E01
            set AppleScript's text item delimiters to "E"
            set eTokens to text items of old_data2
            set old_dataSeason to item 1 of eTokens
            set old_dataEpisode to item 2 of eTokens
            set AppleScript's text item delimiters to old_data2 & ")"
            set epcodeTokens3 to text items of old_data1
            set afterEpcode to item 2 of epcodeTokens3
            set oldnum9 to old_dataSeason & old_dataEpisode as integer
            set oldnum0 to oldnum9 + 90000
            set newnum0 to mySeason2 & myEpisode2 as integer
            set newnum1 to newnum0 + 90001
            set newnum7 to newnum1 as text
            set oldnum7 to oldnum0 as text
            set newnum to text 2 thru 3 of newnum7 & "E" & text 4 thru 5 of newnum7
            set newData to beforeEpcode & newnum & ")" & afterEpcode
            if newnum1 is greater than oldnum0 then
                listOfShows's setStringValue:newData
            else
                listOfShows's setStringValue:old_data0
            end if
            NSTimer's scheduledTimerWithTimeInterval:0 |target|:me selector:"writeList:" userInfo:(missing value) repeats:false
            delay 0.01
    end updateEpcode:
    ###########################################################################
	on appQuit:sender
        NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"writeList:" userInfo:"writeList" repeats:false
        delay 0.01
		tell current application to quit
	end appQuit:
	###########################################################################
	on applicationShouldTerminate:sender
        NSTimer's scheduledTimerWithTimeInterval:0 target:me selector:"theStuckProcess:" userInfo:(missing value) repeats:false
        delay 0.01
        --the below block removes all completed torrents
        set remove1 to do shell script transmission2 & " -l"
        set AppleScript's text item delimiters to "
        "
        set torList to text items of remove1
        repeat with listInt from 1 to ((count of torList))
            if text item listInt of remove1 contains "100%" then
                set remove2 to text item listInt of remove1
                set AppleScript's text item delimiters to {"  100%", "*  100%"}
                set remove3 to (text item 1 of remove2)
                set AppleScript's text item delimiters to "
                "
                do shell script transmission2 & " -t " & remove3 & " -r"
            end if
        end repeat
        do shell script transmission2 & " --torrent all --stop"
        try
            do shell script "pkill transmission-daemon"
        end try
		return current application's NSTerminateNow
	end applicationShouldTerminate:
end script
