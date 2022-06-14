# GiphyAssignment

This app shows a list of Giphy's most popular GIFs and allows the user to search for GIFs.

### Features

UItabbarController with two tabs

- Home
  - 'Trending GIFs' are displayed in a list by default, with a searchbar at the top.
  - The user can also use the searchbar to find specific GIFs..
- Favourite
  - GIFs that users have liked are displayed here, where they can also be disliked.

The user can like or dislike a GIF by tapping the heart image button in the right top corner.

## Project Design

### Folder structure
  - `Application`: Contains project sources (Storyboard, AppDelegate, SceneDelegate, Info.plist)
  - `UI`: Contains all user interfaces like scenes (UIViewController's and their ViewModels) and customViews
  - `Domain`: Contain subfolders like
      - Protocols - Generally classified as feature usecases protocol
      - Repositories - usecase protocol implementations
      - Model - Domain/Data models
  - `Data`: Contains subfloders like
      - PersistentData - Database and their operation files and models
      - Service - Network layer wher we interact with remote server, and response models
  - `Common`: This contains the files that are commonly used across the project

## App Preview - Demo
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Demo.gif?raw=true" width="400"></img>

### Screenshots - Landscape Mode

<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Landscape/1.png?raw=true" width="300"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Landscape/2.png?raw=true" width="300"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Landscape/3.png?raw=true" width="300"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Landscape/4.png?raw=true" width="300"></img>

### Screenshots - Portait Mode

<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Potrait/1.png?raw=true" width="200"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Potrait/2.png?raw=true" width="200"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Potrait/3.png?raw=true" width="200"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Potrait/4.png?raw=true" width="200"></img>
<img src="https://github.com/SrikanthRaju/GiphyAssignment/blob/main/docs/Potrait/5.png?raw=true" width="200"></img>


## Enhancements Required
1. More optimization for asynchronous Image downloading code.


## Todo
1. Error handling to be done
2. Testcase needs to be improved

