'Script for Populating Feed
'Get feed data via roUrlTransfer

sub GetContent()

   'port = CreateObject("roMessagePort")
    'request = CreateObject("roUrlTransfer")
    'request.SetMessagePort(port)
    'request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'request.RetainBodyOnError(true)
    'request.AddHeader ("Authorization", "YOUR UNIQUE ACCESS TOKEN HERE") ' Depends on the backend what the auth token is, but this is general format
    'request.AddHeader("Authorization", "Basic YW5hbnQ6c2FlN3V1YjNBaQ==") ' How I can access from seedbox
    'request.SetRequest("GET")
    'request.SetUrl("https://YOUR SERVER/downloads/server/feed_recco.json")
    'requestSent = request.AsyncGetToString()
    'if (requestSent)
    '    msg = wait(0, port)
    '    if (type(msg) = "roUrlEvent")
    '        statusCode = msg.GetResponseCode()
    '        headers = msg.GetResponseHeaders()
    '        etag = headers["Etag"]
    '        body = msg.GetString()
    '        json = ParseJson(body)
    '    end if
    'end if

    'Reading config from file
    'text=ReadAsciiFile("pkg:/configs/videoview.txt")
    'splitlines = CreateObject("roRegex", "\n", "") ' split on newline
    'pkgregex = CreateObject("roRegex", "^pkg", "") 'check for package
    'test = pkgregex.split(text)
    'lines=splitlines.split(text)
    '?test
    'for each str in lines
    '        ?str.Trim().Replace(chr(34), "") 'trim whitespace and quotes
    'end for


    port = CreateObject("roMessagePort")
    request = CreateObject("roUrlTransfer")
    request.SetMessagePort(port)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.RetainBodyOnError(true)
    request.AddHeader("Authorization", "Basic YOUR-BASE-64-STRING")
    request.SetRequest("GET")
    request.SetUrl("https://yourserverurl/downloads/server/feed.json")
    requestSent = request.AsyncGetToString()
    if (requestSent)
        msg = wait(0, port)
        if (type(msg) = "roUrlEvent")
            statusCode = msg.GetResponseCode()
            headers = msg.GetResponseHeaders()
            etag = headers["Etag"]
            body = msg.GetString()
            json = ParseJson(body)
        end if
    end if
    

     rootNodeArray = ParseJsonToNodeArray(json)
    m.top.content.Update(rootNodeArray)
end sub

function ParseJsonToNodeArray(jsonAA as Object) as Object
    videolist = "movies series For You" ' Add fields here to add playlists
    if jsonAA = invalid then return []
    resultNodeArray = {
       children: []
    }

    ' For Watch list
    'for each fieldInJsonAA in jsonAA
    '    if Instr(1, "movies For You", fieldInJsonAA) <> 0 'and Watchlist_GetWatchlistData(m.top.content.id) <> 0
    '        ?Watchlist_GetWatchlistData(m.top.content.id)
    '        mediaItemsArray = jsonAA[fieldInJsonAA]
    '        itemsNodeArray = []
    '        for each mediaItem in mediaItemsArray
    '            itemNode = ParseMediaItemToNode(mediaItem, fieldInJsonAA)
    '            itemsNodeArray.Push(itemNode)
    '        end for
    '        rowAA = {
    '           title: "Continue Watching"
    '           children: itemsNodeArray
    '        }

          'resultNodeArray.children.Push(rowAA)
       'end if
    'end for

    ' For continue watching
    for each fieldInJsonAA in jsonAA
        if Instr(1, "movies For You", fieldInJsonAA) <> 0 and BookmarksHelper_GetBookmarkData(m.top.content.id) <> 0
            mediaItemsArray = jsonAA[fieldInJsonAA]
            itemsNodeArray = []
            for each mediaItem in mediaItemsArray
                itemNode = ParseMediaItemToNode(mediaItem, fieldInJsonAA)
                itemsNodeArray.Push(itemNode)
            end for
            rowAA = {
               title: "Continue Watching"
               children: itemsNodeArray
            }

           resultNodeArray.children.Push(rowAA)
       end if
    end for
    ' For normal videos
    for each fieldInJsonAA in jsonAA
        ' Assigning fields that apply to both movies and series
        if Instr(1, videolist, fieldInJsonAA) <> 0
            mediaItemsArray = jsonAA[fieldInJsonAA]
            itemsNodeArray = []
            for each mediaItem in mediaItemsArray
                itemNode = ParseMediaItemToNode(mediaItem, fieldInJsonAA)
                '?itemNode
                itemsNodeArray.Push(itemNode)
            end for
            rowAA = {
               title: fieldInJsonAA
               children: itemsNodeArray
            }

           resultNodeArray.children.Push(rowAA)
       end if
    end for
    ' For audio tracks
     for each fieldInJsonAA in jsonAA
        if Instr(1, "Music", fieldInJsonAA) <> 0
            mediaItemsArray = jsonAA[fieldInJsonAA]
            itemsNodeArray = []
            for each mediaItem in mediaItemsArray
                itemNode = ParseMediaItemToNode(mediaItem, fieldInJsonAA)
                itemsNodeArray.Push(itemNode)
            end for
            rowAA = {
               title: "Music"
               children: itemsNodeArray
            }

           resultNodeArray.children.Push(rowAA)
       end if
    end for


    return resultNodeArray
end function

function ParseMediaItemToNode(mediaItem as Object, mediaType as String) as Object
    itemNode = Utils_AAToContentNode({
            "id": mediaItem.id
            "title": mediaItem.title
            "hdPosterUrl": mediaItem.thumbnail
            "Description": mediaItem.shortDescription
            "Categories": mediaItem.genres
            "bookmarkPosition": BookmarksHelper_GetBookmarkData(m.top.content.id)
            "Watchlist" : "false"
            
        })
    itemNode.AddHeader("Authorization", "Basic YW5hbnQ6ZXh0cmFzYWZldHk=")
    if mediaItem = invalid then
        return itemNode
    end if
    if mediaType = "Music"
        Utils_forceSetFields(itemNode,{
            "Url": GetVideoUrl(mediaItem)
            streamFormat : "mp3"
            length: mediaItem.content.duration
            
        })
    end if
    ' Assign movie specific fields
    if mediaType = "movies" 'modify here if you add short form videos
        Utils_forceSetFields(itemNode, {
                "Url": GetVideoUrl(mediaItem)
                length: mediaItem.content.duration
                HandlerConfigEndcard: { ' this is for endcards, see Endcard sample
                    name: "EndcardHandler"
                    fields: {
                        param: "Endcard"
                        currentItemContent: { ' some info can be passed via fields to endcard handler
                            "id": mediaItem.id
                        }
                    }
                }
            })
    end if
    'Subtitle_Tracks.push({"Language":"eng","TrackName":ccUrl,"Description":descriptionForLang})         subtitle_config = { TrackName: ccUrl}

    '   ContentNode_object.subtitleconfig = subtitle_config

    'ContentNode_object.SubtitleTracks = Subtitle_Tracks
    if mediaType = "For You" 'For recommended playlist- consider unifying for all video types
    subtracks = []
    subconf ={}
    if mediaItem.content.captions.Peek() <> invalid
        '?mediaItem.content.captions[0] 'This is only for the first sub file. Add a loop to iterate for all items
        subnode=mediaItem.content.captions[0]
        subtracks.Push({"Language":subnode.language,"TrackName":subnode.url,"Description":"English"})
        subconf={"TrackName":subnode.url}

    end if


    
    Utils_forceSetFields(itemNode, {
                "Url": GetVideoUrl(mediaItem)
                length: mediaItem.content.duration
                SubtitleTracks : subtracks
                subtitleconfig :subconf
            })
    end if


    ' Assign series specific fields
    if mediaType = "series"
        seasons = mediaItem.seasons
        seasonArray = []
        for each season in seasons
            episodeArray = []
            episodes = season.Lookup("episodes")
            for each episode in episodes
                episodeNode = Utils_AAToContentNode(episode)
                Utils_forceSetFields(episodeNode, {
                    "url": GetVideoUrl(episode)
                    "title": episode.title
                    "hdPosterUrl": episode.thumbnail
                    "Description": episode.shortDescription
                    "bookmarkPosition": BookmarksHelper_GetBookmarkData(m.top.content.id)
                    "length": episode.content.duration
                })
                episodeArray.Push(episodeNode)
            end for
            seasonArray.Push(episodeArray)
        end for
        Utils_forceSetFields(itemNode, {
                "seasons": seasonArray
            })
    end if
    return itemNode
end function

function GetVideoUrl(mediaItem as Object) as String
    content = mediaItem.Lookup("content")
    if content = invalid then
        return ""
    end if

    videos = content.Lookup("videos")
    if videos = invalid then
        return ""
    end if

    entry = videos.GetEntry(0)
    if entry = invalid then
        return ""
    end if

    url = entry.Lookup("url")
    if url = invalid then
        return ""
    end if

    return url
end function

sub checkWatchlist()
    text=ReadAsciiFile("pkg:/configs/watchlist.txt")
    splitlines = CreateObject("roRegex", "\n", "") ' split on newline
    lines=splitlines.split(text)
    for each str in lines
            ?str.Trim().Replace(chr(34), "") 'trim whitespace and quotes
    end for
end sub

sub updateWatchlist()

end sub
