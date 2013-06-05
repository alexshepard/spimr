

$(document).ready(function() {
  if (document.getElementById("spime_checkin_div")) {
    navigator.geolocation.getCurrentPosition(
        onSuccess,
        onError,
        {
           enableHighAccuracy: true,
           timeout: 20000,
           maximumAge: 120000
        }
      )
  }
  
  function onSuccess(position) {
    document.getElementById("sighting_latitude").value = position.coords.latitude;
    document.getElementById("sighting_longitude").value = position.coords.longitude;
  }

  function onError(err) {
     var message;

     switch (err.code) {
     case 0:
       message = 'Unknown error: ' + err.message;
       break;
     case 1:
       message = 'You denied permission to retrieve a position.';
       break;
     case 2:
       message = 'The browser was unable to determine a position: ' + error.message;
       break;
     case 3:
       message = 'The browser timed out before retrieving the position.';
       break;
     }
     
     document.getElementById("alert").innerHTML = message
  }

});
