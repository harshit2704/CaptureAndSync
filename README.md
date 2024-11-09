# Project Overview:

The CaptureAndSync app provides functionality to capture images from the device camera, view captured images, and upload them to a server. The images are stored locally in Realm with metadata such as URI, name, capture date, and upload status. The app supports:

- Image capturing and local storage.
- Uploading images to a server with progress tracking.
- Showing the upload status via toast notifications.
- Handling upload retries in case of failure.

## Main Components:

- **CapturedImage Model:**
  This class represents an image stored in Realm. The model inherits from Realm's Object class, allowing it to be stored in the Realm database. It contains details such as:
    - URI: Path to the stored image.
    - Image name.
    - Capture date.
    - Upload status (Pending, Uploading, Uploaded, Failed).
    - Upload progress.

- **CapturedImageViewModel:**
  The CapturedImageViewModel class is responsible for managing the application's image-related logic. It handles the following:
  - Camera session: This class manages the camera session for capturing images. When the user taps the "Capture" button, it uses AVCaptureSession to capture images.
  - Image Uploading: Once an image is captured, this ViewModel attempts to upload the image to the server. The upload is managed through the NetworkManager class, and the status of the upload is tracked.
  - Loading and Saving Images: The ViewModel interacts with Realm to load previously captured images into the app and saves new images (along with their metadata) once they are captured.
  - Image Upload Progress: As the image is being uploaded, the ViewModel listens for updates on the progress of the upload and updates the image's uploadProgress property in the Realm database.

- **ImageListView:**
  This is the main view that lists all captured images. It does the following:
  - List of Images: It presents all the images stored in Realm through a List. Each image is displayed using the ImageRowView, which shows a thumbnail of the image and its upload status.
  - Open Camera: It provides a button to open the camera. When the button is tapped, it sets a state to show the CameraCaptureView.
  - Upload Handling: If an image’s upload has failed, tapping on the image will attempt to upload the image again by calling the uploadImageToServer method.
 
- **CameraCaptureView:**
  This view presents the camera interface for capturing images. It does the following:
  - Camera Preview: The view uses the CameraPreviewView (which wraps an AVCaptureVideoPreviewLayer) to show a live camera feed. This is the part of the screen where the user can see what the camera sees.
  - Capture Button: A button is placed at the bottom of the screen that, when tapped, triggers the capture of an image. The image is then passed back to the CapturedImageViewModel, which stores the image data and other metadata.

- **CameraPreviewView:**
  This view is a SwiftUI wrapper around a UIView that displays the camera feed using AVFoundation. It uses AVCaptureVideoPreviewLayer to render the camera feed onto the screen.
  - UIViewRepresentable: This protocol allows a UIKit-based component (like AVCaptureVideoPreviewLayer) to be used within a SwiftUI view.
  - makeUIView and updateUIView: These methods manage the lifecycle of the preview layer. makeUIView creates the view, and updateUIView adjusts the size of the preview layer when the view’s bounds change.

- **NetworkManager:**
  The NetworkManager class handles all the networking tasks related to uploading images:
  - Uploading Images: When an image is ready to be uploaded, the uploadImage method is called. This method sends the image to a server using a multipart/form-data POST request. The image is sent in the request body, and the progress is tracked during the upload.
  - Progress Handling: The URLSessionTaskDelegate methods are used to monitor the upload progress. As data is sent, the delegate method didSendBodyData is called, and the uploadProgress is updated.
  - Status Updates: After the upload is complete (either successful or failed), the updateStatus method is called to update the image’s status in Realm and trigger a toast notification. If the upload was successful, a "Upload completed" toast is shown.

- **ToastManager:**
  The ToastManager is a singleton class responsible for managing and displaying toast notifications:
  - showToast: This method sets the message to display and triggers the visibility of the toast. The toast will automatically disappear after 3 seconds (using DispatchQueue.main.asyncAfter).
  - ObservableObject: The ToastManager is an observable object, meaning it can be used within SwiftUI views to dynamically show/hide toasts based on the state of the app.
  - Binding: The ToastManager is observed by the ToastView (the view responsible for rendering the toast).

- **Extensions:**
  The Extensions.swift file defines additional functionality for the Data type:
  - Appending a String to Data: A custom append method is added to the Data class, which allows appending a String to a Data object. This is used when constructing the multipart form data for the image upload.

## Overall Flow: 
1. Capture Image: The user taps the "Open Camera" button, and the CameraCaptureView is presented. The user captures an image, which is then passed to the CapturedImageViewModel.
2. Save Image: The image data, along with the other metadata (URI, image name, etc.), is saved into Realm using the CapturedImage model.
3. Upload Image: The image upload process is triggered by the NetworkManager. The image is uploaded to the server, and progress is tracked. The status of the image is updated in Realm, and a toast notification is displayed based on the upload result.
4. View Images: The images are displayed in ImageListView, and their upload status is updated in real-time. If an upload fails, tapping the image will retry the upload.

## Important Technologies Used
- AVFoundation: For accessing the camera and capturing images.
- SwiftUI: For building the UI, including UIViewRepresentable to integrate UIKit components.
- Realm: For local storage of captured images and their metadata.
- URLSession: For handling the image upload and tracking progress.








