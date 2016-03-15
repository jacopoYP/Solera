# Solera


The test app has been developed with xCode 7.2 and Objective-C.


### General comments

- App is universal and it fits all possible devices and orientations, from iPhone4s to iPad Pro
- If no item is selected, the 'Checkout' button is disabled.
- Spending more time on it, the UI and UX could be improved, e.g. adding interactive coachmarks  / tutorial, better graphic elements, refinements, etc
- I created a singleton class for useful methods, like network services
- Supporting offline and errors during fetching currencies' list or exchange rate for a given currency
- I used constraints with priorities and auto-layout
- As soon as the app is launched, items are loaded via a JSON file. In this way it's easy to add items or even fetch them from a remote service
- App can handle a big number of items, not just the given four
- It's possible to search for an item
- I used several elements like Collection View, Table View and Picker View
- I created some basic Unit and UI tests