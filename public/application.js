$(function() {
  player_hits();
  player_stays();
  dealer_hit();
});

function player_hits() {
  $(document).on("click", "#hit-btn", function(e) {
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: "/game/player/hit"
    }).done(function(data){
      $("#game").replaceWith(data);
    });
  });
}

function player_stays() {
  $(document).on("click", "#stay-btn", function(e) {
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: "/game/player/stay"
    }).done(function(data){
      $("#game").replaceWith(data);
    });
  });
}

function dealer_hit() {
  $(document).on("click", "#dealer_hit", function(e) {
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: "/game/dealer/hit"
    }).done(function(data){
      $("#game").replaceWith(data);
    });
  });
}