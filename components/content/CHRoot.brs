'Script for Populating Feed
'Get feed data via roUrlTransfer

sub GetContent()

    ' Will need to check if user is Auth'd with the channel to fetch recommendations. Will come back once Activation is done (towards end of eval one)
    ' Something like if (userauthtoken <> invalid) then fetch recommendation. else fetch default feed
    'port = CreateObject("roMessagePort")
    'request = CreateObject("roUrlTransfer")
    'request.SetMessagePort(port)
    'request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'request.RetainBodyOnError(true)
    'request.AddHeader ("Authorization", "YOUR UNIQUE ACCESS TOKEN HERE") ' Depends on the backend what the auth token is, but this is general format
    'request.AddHeader("Authorization", "Basic YW5hbnQ6c2FlN3V1YjNBaQ==") ' How I can access from seedbox
    'request.SetRequest("GET")
    'request.SetUrl("https://fremicro029.xirvik.com/downloads/server/feed_recco.json")
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

    port = CreateObject("roMessagePort")
    request = CreateObject("roUrlTransfer")
    request.SetMessagePort(port)
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.RetainBodyOnError(true)
    request.AddHeader("Authorization", "Basic YW5hbnQ6c2FlN3V1YjNBaQ==")
    request.SetRequest("GET")
    request.SetUrl("https://fremicro029.xirvik.com/downloads/server/feed.json")
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

    for each fieldInJsonAA in jsonAA
        ' Assigning fields that apply to both movies and series
        if Instr(1, videolist, fieldInJsonAA) <> 0
            mediaItemsArray = jsonAA[fieldInJsonAA]
            itemsNodeArray = []
            for each mediaItem in mediaItemsArray
                itemNode = ParseMediaItemToNode(mediaItem, fieldInJsonAA)
                itemsNodeArray.Push(itemNode)
            end for
            rowAA = {
               title: fieldInJsonAA
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
        })

    if mediaItem = invalid then
        return itemNode
    end if

    ' Assign movie specific fields
    if mediaType = "movies" 'modify here if you add short form videos (Note: endcard handler currently breaks for recommended playlist)
        Utils_forceSetFields(itemNode, {
                "Url": GetVideoUrl(mediaItem)
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

    if mediaType = "For You" 'For recommended playlist- consider unifying for all video types
    Utils_forceSetFields(itemNode, {
                "Url": GetVideoUrl(mediaItem)
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
