importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyAyLt2_FAHc0I2c1iBLH_MxWzo2kllSvA8",
  authDomain: "allo-ms.firebaseapp.com",
  projectId: "allo-ms",
  storageBucket: "allo-ms.appspot.com",
  messagingSenderId: "1049075385887",
  appId: "1:1049075385887:web:89f4887e574f8b93f2372a",
  measurementId: "G-N5D9CRB413"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();