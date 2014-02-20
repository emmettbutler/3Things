- [x] create new user
- [x] login existing user
- [x] photo for new user
- [x] batch post 3 things for day
- [x] images for things
- [x] get user info
- [x] get user history

Unfinished posts
- [x] give all old posts a "published" flag, set to true
- [x] only return posts in feed where published=True
- [x] only return posts in calendar where published=True
- [x] new server endpoint for unpublished calendar view
- [x] new TTNetManager interface for this endpoint
- [x] save completed posts with published=True
- [x] post unfinished days from review button to web
- [x] "Share" button should say "save" for unfinished posts
- [x] post unfinished days on edit screen "save" button
- [x] add switch above user history scroll view
- [x] only return posts in new calendar where published=False
- [x] allow client to send separate timestamp and day values
- [x] touch an unfinished post in this view to edit it
- [x] post unfinished days from unfinished post view to web
- [x] touch an empty post in this view to edit it
- [x] post unfinished days from empty post view to web
- [ ] exclude days with published posts from the unpublished feed (currently they appear as empty days)
    when the client requests unpublished posts, include published (don't show
    these on the client, but use them to determine which blank days to show?)
    when client requests published, show only published
    when client requests unpublished, show *all*. client should perform
    filtering??
- [ ] UI polish on unpublished calendar view

Bugs
- [x] splash screen
- [x] nav button active colors
- [x] friend feed date view says null
- [x] hide status bar?
- [x] stop edit screen back arrow from moving around
- [ ] some new posts appear after older ones in the friends feed
- [ ] off-center loading spinner on feed
- [ ] show updated comment counts on day view immediately after commenting
- [ ] horizontally align nav elements on feed
- [ ] show new post in calendar immediately upon posting
- [ ] loading spinner is infinite when user has no posts
- [ ] typo and resize on intro quote
