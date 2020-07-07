'Draws the Springboard
function ShowDetailsView(content as Object, index as Integer) as Object
    m.details = CreateObject("roSGNode", "DetailsView")
    m.details.SetFields({
        content: content
        jumpToItem: index
    })
    m.details.ObserveField("itemLoaded", "OnDetailsItemLoaded") 'Comment out if not using prebuffering
    m.details.ObserveField("currentItem","OnDetailsContentSet")
    m.details.ObserveField("buttonSelected", "OnButtonSelected")
    m.top.ComponentController.CallFunc("show", {
        view: m.details
    })
    m.details.theme = {
    OverhangoptionsText: "Search and Options"
    }
    return m.details
end function

'Handle buttons creation
sub OnDetailsContentSet(event as Object)
    details = event.GetRoSGNode()
    currentItem = event.GetData()
    if currentItem <> invalid
        buttonsToCreate = []

        if currentItem.url <> invalid and currentItem.url <> ""
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
'comment out if not using prebuffering
sub OnDetailsItemLoaded()
    ' create a media view so we can start preloading content
    ' we won't show this view until the user selects the "Play" button on the DetailsView
    AddBookmarksHandler(m.details.content)
    m.video = CreateObject("roSGNode", "MediaView")
    httpAgent = CreateObject("roHttpAgent")
    m.video.HttpHeaders = "Authorization:Basic YW5hbnQ6c2FlN3V1YjNBaQ=="
    m.video.setHttpAgent(httpAgent)
    m.video.ObserveFieldScoped("wasClosed", "OnVideoWasClosed")
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
    }

    ' preloading also works while endcards are displayed
    m.video.alwaysShowEndcards = true

    m.video.content = m.details.content
    m.video.jumpToItem = m.details.itemFocused

    ' turn on preloading
    ' it's off by default for backward compatibility
    m.video.preloadContent = true
end sub
'Handle User Interaction
sub OnButtonSelected(event as Object)
    details = event.GetRoSGNode()
    selectedButton = details.buttons.GetChild(event.GetData())
    item = details.content.GetChild(details.itemFocused)

    if selectedButton.id = "play"
         'OpenVideoView(details.content, details.itemFocused) '- Non Prebuffer way (Uncomment if you want to support older devices)
        item.bookmarkPosition = 0 ' Reset bookmark
        m.video.ObserveField("wasClosed", "OnVideoWasClosed")
        m.video.control = "play"
        m.top.ComponentController.CallFunc("show", { 'Since we have already made the video view, all we need to do is show it
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
    ' play button is always available
    buttons = [{ title: "Play", id: "play" }]
    ' continue button available only when this item has bookmark
    if item.bookmarkPosition > 0 then buttons.Push({ title: "Continue", id: "continue" })
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
                interval : 10 ' bookmark saving interface
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
        video = OpenVideoPlayerItem(item)
        video.ObserveField("endcardItemSelected", "OnEndcardItemSelected")
    end if
    ' ? "OnEndcardItemSelected item == "; item
end sub