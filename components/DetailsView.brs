'Draws the Springboard
function ShowDetailsView(content as Object, index as Integer) as Object
    m.details = CreateObject("roSGNode", "DetailsView")
    m.details.SetFields({
        content: content
        jumpToItem: index
    })
    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded")'Comment out if not using prebuffering
     
    m.details.ObserveField("currentItem","OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })
    m.details.theme = {
    OverhangoptionsText: "Search and Options"
    }
    'Code for how to add components as children to the view
    'MoreLikeThisGroup = m.top.CreateChild("LayoutGroup")
    'MoreLikeThisGroup.translation = [640, 580]
    'MoreLikeThisGroup.horizAlignment = "center"
    'MoreLikeThisGroup.vertAlignment = "center"
    'm.rowlist = MoreLikeThisGroup.CreateChild("RowList")
    
    'm.spinner = MoreLikeThisGroup.CreateChild("BusySpinner")
    'm.spinner.visible = true
    'm.spinner.uri = "pkg:/components/SGDEX/Images/loader.png"
    'Something like 
    'content = CreateObject("roSGNode", "ContentNode")
    'content.AddFields({
    '    HandlerConfigGrid: {
    '        name: "MoreLikeThisHandler"
    '    }
    '})
    'm.rowList.content = content '- add a content handler here to add a row with titles in the same category/tag
    'm.rowList.numRows = 3
    'm.rowList.itemSize = [ 180*3 + 20*2, 250 ]
    'm.rowList.visible = true
    return m.details
end function

'Handle buttons creation
sub OnDetailsContentSet(event as Object)
    details = event.GetRoSGNode()
    currentItem = event.GetData()
    if currentItem <> invalid
        buttonsToCreate = []

        if details.content.TITLE = "Music"
            buttonsToCreate.Push({ title: "Play Track", id: "playaudio" })
            btnsContent = CreateObject("roSGNode", "ContentNode")
            btnsContent.Update({ children: buttonsToCreate })
            details.buttons = btnsContent

        'else if details.content.TITLE = "Podcasts"
        '    refreshaudiobuttons
        '    btnsContent = CreateObject("roSGNode", "ContentNode")
        '    btnsContent.Update({ children: buttonsToCreate })
        '    details.buttons = btnsContent

        else if currentItem.url <> invalid and currentItem.url <> ""
            ?"Refresh buttons called from OnDetailsContentSet"
            RefreshButtons(details) 'Make play available by default, add a Play again if bookmarks are present
        else if details.content.TITLE = "series"
            buttonsToCreate.Push({ title: "Episodes", id: "episodes" })
            btnsContent = CreateObject("roSGNode", "ContentNode")
            btnsContent.Update({ children: buttonsToCreate })
            details.buttons = btnsContent

        else
            buttonsToCreate.Push({ title: "No Content to play", id: "no_content" })
            btnsContent = CreateObject("roSGNode", "ContentNode")
            btnsContent.Update({ children: buttonsToCreate })
            details.buttons = btnsContent
        end if
        
    end if

end sub

  'For using a DRM system/CDN
  'contentNode.KeySystem = "playready"
  'contentNode.streamFormat = "dash"
  'contentNode.encodingType = "PlayReadyLicenseAcquisitionUrl"
  'contentNode.encodingKey = m.drmKeyUrl

'comment out if not using prebuffering
sub OnDetailsItemLoaded()
    ' create a media view so we can start preloading content
    ' we won't show this view until the user selects the "Play" button on the DetailsView
    AddBookmarksHandler(m.details.content,m.details.itemFocused)
    m.video = CreateObject("roSGNode", "MediaView")
    httpAgent = CreateObject("roHttpAgent")
    m.video.setCertificatesFile("common:/certs/ca-bundle.crt")
    m.video.InitClientCertificates()
    m.video.AddHeader("Authorization", "Basic YW5hbnQ6ZXh0cmFzYWZldHk=") ' doesn't work yet
    m.video.setHttpAgent(httpAgent)
    ' we'll use this observer to print the state of the MediaView to the console
    ' this let's us see when prebuffering starts
    m.video.ObserveField("state", "OnVideoState")
    m.video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    m.video.theme = {
        OverhangVisible : "false"
        trickPlayBarFilledBarImageUri :  "pkg:/images/bar.9.png"
        bufferingBarFilledBarImageUri : "pkg:/images/bar.9.png"
        bufferingBarEmptyBarImageUri : "pkg:/images/bar.9.png"
        bufferingBarTrackImageUri : "pkg:/images/bar.9.png"
        backgroundImageURI : "pkg:/images/logo.png"
        backgroundColor: "FF0000FF"
    }
    'm.global.id=m.video.hdPosterUrl

    ' preloading also works while endcards are displayed
    m.video.alwaysShowEndcards = true

    m.video.content = m.details.content
    m.video.jumpToItem = m.details.itemFocused

    ' turn on preloading
    ' it's off by default for backward compatibility
    m.video.preloadContent = true
    m.video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")
end sub
'Handle User Interaction
sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())
    item = details.content.GetChild(details.itemFocused)
    ?item
    ?item.categories[0]
    if selectedButton.id = "play"
         'OpenVideoView(details.content, details.itemFocused) '- Non Prebuffer way (Uncomment if you want to support older devices)
        item.bookmarkPosition = 0 ' Reset bookmark
        OnVideoWasClosed() 'Reload video since the preloaded one loaded with bookmark
        m.video.ObserveField("wasClosed", "OnVideoWasClosed")
        m.video.control = "play"
        m.top.ComponentController.CallFunc("show", { 
        view: m.video
    })
    else if selectedButton.id = "continue" 
         'OpenVideoView(details.content, details.itemFocused) '- Non Prebuffer way (Uncomment if you want to support older devices)
        'don't reset if continuing
        m.video.ObserveField("wasClosed", "OnVideoWasClosed")
        m.video.control = "play"
        m.top.ComponentController.CallFunc("show", { 'Since we have already made the video view, all we need to do is show it
        view: m.video
    })    
    else if selectedButton.id = "episodes"
        if details.currentItem.seasons <> invalid then
            ShowEpisodePickerView(details.currentItem.seasons)
        end if
    else if selectedButton.id = "playaudio"
        OnAudioDetailsItemLoaded()
        if m.audio <> invalid
            ?m.audio
            m.audio.control = "play"
            ' Show the Audio view
            m.top.ComponentController.callFunc("show", {
                view: m.audio
            })
        end if
    
    else if selectedButton.id ="More"
        OpenSearch(item.categories[0]) ' DOES NOT WORK FOR SERIES NODES RIGHT NOW. FIX THE FEED
    else
        ' handle all other button presses
    end if
end sub
'comment this out if not using prebuffering
sub OnVideoState(event)
  ? "OnVideoState " + m.video.state
end sub

sub OnVideoWasClosed()
    m.video = invalid ' clear played video node
    OnDetailsItemLoaded() ' start buffering new one (this is how you play though a whole playlist)
    RefreshButtons(m.details)
end sub


' function for refreshing buttons on details View
' it will check whether item has bookmark and show correct buttons
sub RefreshButtons(details as Object)
    item = details.content.GetChild(details.itemFocused)
    ' continue button available only when this item has bookmark
    if item.bookmarkPosition > 0 
        buttons = [{ title: "Continue Watching", id: "continue" }]
        buttons.Push({ title: "Play from the beginning", id: "play" })
    else ' play button is always available
        buttons = [{ title: "Play title", id: "play" }]
    end if
    if item.Watchlist = "false"
        buttons.Push({ title: "Add to watch list", id: "watch" })
    else 
        buttons.Push({ title: "Remove from watch list", id: "remove" })
    end if
    buttons.Push({ title: "More like this", id: "More" })
    btnsContent = CreateObject("roSGNode", "ContentNode")
    btnsContent.Update({ children: buttons })
    ' set buttons
    details.buttons = btnsContent
end sub

'Adding bookmark handler to video
sub AddBookmarksHandler(contentItem as Object, index = invalid as Object)
    if index <> invalid then contentItem = contentItem.GetChild(index)
    if contentItem = invalid then return
    contentItem.AddFields({
            HandlerConfigBookmarks: {
            name: "RegistryBookmarksHandler"
            fields: {
                minBookmark: 10
                maxBookmark: 10
                'interval : 10 ' bookmark saving interface
            }
        }
    })
end sub

sub OnEndcardItemSelected(event as Object)
    item = event.GetData()
    video = event.GetRoSGNode()
    video.UnobserveField("endcardItemSelected")
    video.close = true

    if item.url <> invalid
        video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    end if
    ' ? "OnEndcardItemSelected item == "; item
end sub

sub OnAudioDetailsItemLoaded()
    ClearMediaPlayer() ' Reseting MediaView
    m.audio = CreateMediaPlayer(m.details.content, m.details.itemFocused)
    m.audio.ObserveFieldScoped("wasClosed", "OnMediaWasClosed")
end sub

sub OnMediaWasClosed()
    m.details.jumpToItem = m.audio.currentIndex 'moving focus to proper item on details row
    ClearMediaPlayer() ' clear player
    OnAudioDetailsItemLoaded() ' start buffering new one
end sub

sub ClearMediaPlayer()
    if m.audio <> invalid
        m.audio.UnobserveFieldScoped("wasClosed")
        m.audio = invalid
    end if
end sub