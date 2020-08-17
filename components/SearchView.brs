sub OpenSearch(query as string)
    searchView = CreateObject("roSGNode", "SearchView")
    searchView.hintText = "Enter search term"
    ' query field will be changed each time user has typed something
    searchView.ObserveFieldScoped("query", "OnSearchQuery")
    if query <> "" 'Check if Search is being called from More Like This
        searchView.query = query
        searchView.hintText = "Items related to title"
    end if
    searchView.ObserveFieldScoped("rowItemSelected", "OnSearchItemSelected")
    searchView.theme = {
        OverhangoptionsText: "Toggle caps lock"
    }
    ?searchView

    ' this will trigger job to show this screen
    m.top.ComponentController.CallFunc("show", {
        view: searchView
    })
end sub

sub OnSearchQuery(event as Object)
    query = event.GetData()
    searchView = event.GetRoSGNode()

    content = CreateObject("roSGNode", "ContentNode")
    if query.Len() > 2 ' perform search if user has typed at least three characters
        content.AddFields({
            HandlerConfigSearch: {
                name: "CHSearch"
                query: query ' pass the query to the content handler
            }
        })
    end if
    ' setting the content with handlerConfigSearch will create the content handler where search should be performed
    ' setting the clear content node or invalid will clear the grid with results
    searchView.content = content
end sub

'Function to call details view from search
sub OnSearchItemSelected(event as Object)
    grid = event.GetRoSGNode()
    selectedIndex = event.GetData()
    row = grid.content.GetChild(selectedIndex[0])
    detailsView = ShowDetailsView(row, selectedIndex[1])
end sub