$(document).ready(function() {
	var navTop = $('nav').offset().top - parseFloat($('nav').css('margin-top').replace(/auto/,0));
	var socialHeight = $('.social').outerHeight();

	$(window).scroll(function() {
		var windowTop = $(this).scrollTop();

		if (windowTop >= navTop) {
			$('nav').addClass('top_fixed');
			$('#top_shift').addClass('visible');
		} else {
			$('nav').removeClass('top_fixed');
			$('#top_shift').removeClass('visible');
		}

		if (windowTop >= navTop - socialHeight) {
			$('.social').appendTo('nav');
			$('.social').addClass('nav_mode');
		} else {
			$('.social').appendTo('header');
			$('.social').removeClass('nav_mode');
		}
	});
});