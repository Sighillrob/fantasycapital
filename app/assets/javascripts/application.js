// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require underscore.min
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require moment.min
//= require bootstrap-sortable
//= require bootstrap-modal
//= require bootstrap-modalmanager
//= require app
//= require jquery.countdown
//= require ajax_modal
//= require turbolinks
//= require social-share-button
//= require plugins/local_date
//= require plugins/time_remaining
//= require bootstrap_run
//= require jquery.currency
//= require player
//= require entries
//= require contest
//= require balanced
//= require account
//= require gamecenter
//= require_tree .

$(document).ready(function(){
	$('.require-signin').click(function(e){
		e.preventDefault();
		var target_url = $(this).attr('href');
		window.target_url = target_url;
		new window.AjaxModal('/users/signin_popup').load();
	});

	$('.welcome-text > a').click(function(e){
		e.preventDefault();
		$('.usermenu').toggle();
	});
});


function isEmailAddress(str) {
	var emailRegxp =/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
	if(!emailRegxp.test(str)) {
		return false;
	}
	return true;
}
