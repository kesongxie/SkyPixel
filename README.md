# SkyPixel
Follow and share nearby drone footage at your finger tip. Edit (README.md, coming soon)

Author: Kesong Xie

Time Spent: 3 weeks

Language: Objective-C

Testing Environment: iPhone physical device running iOS 10.2, Xcode Version 8.2 beta

Testing: Go to the right upper corner search icon and enter one of the following location that has already had videos associated with it: UCSD, Stanford University, Eiffel Tower, Madison Square Garden(You may also try to compose a new video and the video will appear at the location associated with it)

Deployment Target: iOS 10 and above

<h1>Frameworks Used</h1>
<ul>
  <li>MapKit</li>
  <li>CloudKit</li>
  <li>Photos</li>
  <li>AVFoundation</li>
  <li>Foundation</li>
  <li>CoreLocation</li>
  <li>UIKit</li>
</ul>

<h1>Features Highlighted</h1>
<ul>
  <li>Search video footage near your current location or a spot with your preference
  <br/>
  Technical Keywords: <strong>MapKit, UISearchController, Cloudkit</strong>
  </li>
  <li>View video footage details including video content, title, location associated with the footage, number of viewers, description, author and more 
   <br/>
   Technical Keywords: <strong>AVFoundation, CLGeocoder/CoreLocation, Cloudkit, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning</strong>
   </li>
  <li>Users can favor or comment a specific video shot
   <br/>
  Technical Keywords: <strong>UITableView, Cloudkit</strong>
  </li>
  <li>Each user has his or her own profile page listing all the video footage he or she shared, other information includes streachy cover photo, profile picture, fullname, nationality(with a flag), bio.(The follower functionality coming soon)
   <br/>
  Technical Keywords: <strong>UICollectionView, UICollectionViewFlowLayout, UIScrollViewDelegate</strong>
  </li>
  <li>A left slide out navigation panel for easily navigating to the logged-in user's profile and it also includes sharing button for composing a shot
    <br/>
   Technical Keywords: <strong> ContainerView, Embed segue</strong>
  </li>
  <li>Customized video picker interface that allows user to pick videos from user's own libaray with ease and use it to compose a post, and the user may also include a title for the video, the location name(the App automatically extract location information from the video asset and fill it in the input text field automatically), short description, the devices used for shooting the video(current supporting devices availabe for user to select from are mostly DJI's products, including Phantom 4 Pro, Mavic, Inspire series, etc)
   <br/>
   <strong>Technical Keywords: Photos, AVFoundation, UICollectionView, UICollectionViewFlowLayout, CloudKit, GeoCoder</strong>
  </li>
   <li>The App supports both English and Chinese(Simplified Han)
    <br/>
   Technical Keywords: <strong> Internationalization and Localization, NSLocalizedString</strong>
  </li>
  <li>Live streaming video(with DJI iOS SDK)coming soon</li>
</ul>

<h1>Screen Shot Demostration</h1>
<div>
<img src="https://github.com/kesongxie/SkyPixel/blob/master/SkyPixel/screen%20shot%20/ShowCase.png">
</div>


<h1>Video Walk Through</h1>
<ul>
<li>
<a href="https://www.dropbox.com/s/7uobrhturzihfir/SkyPixel%20Walk%20Through.MOV.mov?dl=0">Feature Walk Through</a>
</li>
<li>
<a href="https://www.dropbox.com/s/f59llqbn5sgjtse/Localization.MOV.mov?dl=0">Localization</a>
</li>
</ul>
