# SpotAFire App – Image Feed Feature

Demo iOS app with educational purposes

# BDD Specs

### Story: Customer requests to see their image feed

### Narrative #1

> As an online customer
I want the app to automatically load the latest image feed
So I can always enjoy the newest images of users

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
When the customer requests to see their feed
Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

### Narrative #2

> As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of other users

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
And there’s a cached version of the feed
When the customer requests to see the feed
Then the app should display the latest feed saved

Given the customer doesn't have connectivity
And the cache is empty
When the customer requests to see the feed
Then the app should display an error message
```

## Use Cases

### Load Spots Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Spots" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates spot items from valid data.
5. System delivers spots.

#### Invalid data – error course (sad path):
1. System delivers error.

#### No connectivity – error course (sad path):
1. System delivers error.

### Load Spots Fallback (Cache) Use Case

#### Data:
- Max age

#### Primary course:
1. Execute "Retrieve Spot Items" command with above data.
2. System fetches feed data from cache.
3. System validates cache age.
4. System creates spot items from cached data.
5. System delivers spot items.

#### Expired cache course (sad path): 
1. System delivers no spot items.

#### Empty cache course (sad path): 
1. System delivers no spot items.


## Model Specs

### Feed Item

| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `author`      | `String`            |
| `description` | `String` (optional) |
| `likes`       | `Int`               |
| `image`       | `URL`               |
